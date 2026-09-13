const express=require("express"),mysql=require("mysql2/promise"),excel_js=require("exceljs"),fs=require("fs"),path=require("path");
require("dotenv").config();

const app=express(),port=process.env.PORT||8050,model_path=path.join(__dirname,"model.sql");
app.use(express.json({limit:"2mb"}));
app.use(express.static(path.join(__dirname,"public")));

const pool=mysql.createPool({
    host:process.env.DB_HOST,port:process.env.DB_PORT,user:process.env.DB_USER,
    password:process.env.DB_PASSWORD,database:process.env.DB_NAME,
    waitForConnections:true,connectionLimit:5,multipleStatements:true
});

const products=[
    [1,"adult_annual","1-Year $50","1_Year_50"],
    [2,"adult_annual","3-Year","3_Year"],
    [3,"adult_annual","Silver","Silver"],
    [4,"adult_annual","Gold","Gold"],
    [5,"adult_annual","Lifetime","Lifetime"],
    [6,"adult_annual","Platinum - Foundation","Platinum_Foundation"],
    [7,"adult_annual","Platinum - Team USA","Platinum_USA"],
    [8,"adult_annual","Young Adult - $36","Young_Adult_36"],
    [9,"adult_annual","Young Adult - $40","Young_Adult_40"],
    [11,"elite","Elite","Elite"],
    [12,"elite","Elite 2-Year membership","Elite_2_Year"],
    [14,"one_day","One Day - $15","One_Day_15"],
    [15,"one_day","Bronze - Bike","bronze_bike"],
    [16,"one_day","Bronze - Swim","bronze_swim"],
    [17,"one_day","Bronze - Run","bronze_run"],
    [18,"one_day","Bronze - Relay","Bronze_Relay"],
    [19,"one_day","Bronze - Sprint","Bronze_Sprint"],
    [20,"one_day","Bronze - Intermediate","Bronze_Intermediate"],
    [21,"one_day","Bronze - Ultra","Bronze_Ultra"],
    [22,"one_day","Bronze - AO","Bronze_AO"],
    [23,"one_day","Bronze - $0","Bronze_$0"],
    [24,"one_day","Bronze - Distance Upgrade","Bronze_Upgrade"],
    [25,"one_day","Club","Club"],
    [26,"one_day","Bronze Community Membership","bronze_community"],
    [28,"youth_annual","Youth Annual","Youth_Annual"],
    [29,"youth_annual","Youth Premier - $25","Youth_Premier_25"],
    [30,"youth_annual","Youth Premier - $30","Youth_Premier_30"],
    [999,"multiple","Unknown","Unknown"]
].map(([sort_order,type,name,key])=>({sort_order,type,name,key}))
 .sort((a,b)=>a.sort_order-b.sort_order);

const parse_value=v=>{
    v=v.trim();
    if((v.startsWith("'")&&v.endsWith("'"))||(v.startsWith('"')&&v.endsWith('"'))) return v.slice(1,-1);
    const n=Number(v); return Number.isNaN(n)?v:n;
};

const get_model_variables=()=>{
    const sql=fs.readFileSync(model_path,"utf8"),variables={};
    for(const m of sql.matchAll(/^\s*SET\s+@([A-Za-z0-9_$]+)\s*=\s*([^;]+);/gmi)) variables[m[1]]=parse_value(m[2]);
    return variables;
};

const sql_value=v=>v===null?"NULL":typeof v==="number"?String(v):`'${String(v).replace(/'/g,"''")}'`;

const replace_variable=(sql,name,value)=>{
    name=name.replace(/^@/,"");
    if(!/^[A-Za-z0-9_$]+$/.test(name)) throw new Error(`Invalid variable: ${name}`);

    const escaped_name=name.replace(/[.*+?^${}()|[\]\\]/g,"\\$&");
    const regex=new RegExp(`SET\\s+@${escaped_name}\\s*=\\s*[^;]*;`,"i");

    if(!regex.test(sql)) throw new Error(`@${name} not found in model.sql`);
    return sql.replace(regex,`SET @${name} = ${sql_value(value)};`);
};

const set_variables=async(connection,variables)=>{
    for(const [key,value] of Object.entries(variables))
        if(/^[A-Za-z0-9_$]+$/.test(key)) await connection.query(`SET @${key} = ?`,[value]);
};

let last_variables=get_model_variables();

const months=Array.from({length:12},(_,i)=>i+1);
const month_columns=fn=>months.map(m=>`${fn(m)} AS \`${m}\``).join(",\n");

const matrix_query=(label,parts)=>parts.map(p=>`
    SELECT '${label}' AS query_label,COALESCE(type_goal,'Grand Total') AS type_goal,'${p.metric}' AS metric,
    ${month_columns(p.month)},${p.total} AS Grand_Total
    FROM sales_model_2027
    GROUP BY type_goal WITH ROLLUP
`).join("\nUNION ALL\n");

const this_year_revenue=m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2)`;
const this_year_units=m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)`;
const next_year_revenue=m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2)`;
const next_year_units=m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)`;

const this_year_price=m=>`ROUND(
    SUM(CASE WHEN month_goal=${m} THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END) /
    NULLIF(SUM(CASE WHEN month_goal=${m} THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
)`;

const next_year_price=m=>`ROUND(
    SUM(CASE WHEN month_goal=${m} THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) /
    NULLIF(SUM(CASE WHEN month_goal=${m} THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2
)`;

const reports={
    raw:{
        title:"0 - Raw Data",
        sql:`SELECT * FROM sales_model_2027 ORDER BY month_goal,category_sort_order_goal LIMIT 500`
    },

    month:{
        title:"1 - By Month",
        sql:`
            SELECT 
                month_goal,COUNT(*) AS row_count,
                FORMAT(SUM(sales_units_this_year_estimate),0) AS sales_units_this_year_estimate,
                FORMAT(SUM(sales_rev_this_year_estimate),0) AS sales_rev_this_year_estimate,
                FORMAT(SUM(sales_units_this_year_estimate_nonbulk),0) AS sales_units_this_year_estimate_nonbulk,
                FORMAT(SUM(sales_rev_this_year_estimate_nonbulk),0) AS sales_rev_this_year_estimate_nonbulk,
                FORMAT(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2) AS non_bulk_price_this_year_effective,
                FORMAT(SUM(sales_units_next_year_goal_nonbulk),0) AS sales_units_next_year_goal_nonbulk,
                FORMAT(SUM(sales_rev_next_year_goal_nonbulk),0) AS sales_rev_next_year_goal_nonbulk,
                FORMAT(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2) AS non_bulk_price_next_year_effective,
                FORMAT(SUM(sales_units_next_year_goal_post_race),0) AS sales_units_next_year_goal_post_race,
                FORMAT(SUM(sales_rev_next_year_goal_post_race),0) AS sales_rev_next_year_goal_post_race
            FROM sales_model_2027
            GROUP BY month_goal WITH ROLLUP
            ORDER BY month_goal
        `
    },

    category:{
        title:"2 - By Category",
        sql:`
            SELECT 
                type_goal,category_goal,MIN(category_sort_order_goal) AS category_sort_order,COUNT(*) AS row_count,
                FORMAT(SUM(sales_units_this_year_estimate),0) AS sales_units_this_year_estimate,
                FORMAT(SUM(sales_rev_this_year_estimate),0) AS sales_rev_this_year_estimate,
                FORMAT(SUM(sales_units_this_year_estimate_nonbulk),0) AS sales_units_this_year_estimate_nonbulk,
                FORMAT(SUM(sales_rev_this_year_estimate_nonbulk),0) AS sales_rev_this_year_estimate_nonbulk,
                MAX(price_this_year_actual) AS price_this_year_actual,
                FORMAT(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2) AS non_bulk_price_this_year_effective,
                FORMAT(SUM(sales_units_next_year_goal_nonbulk),0) AS sales_units_next_year_goal_nonbulk,
                FORMAT(SUM(sales_rev_next_year_goal_nonbulk),0) AS sales_rev_next_year_goal_nonbulk,
                MAX(price_next_year_actual) AS price_next_year_actual,
                FORMAT(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2) AS non_bulk_price_next_year_effective
            FROM sales_model_2027
            GROUP BY type_goal,category_goal WITH ROLLUP
            ORDER BY type_goal,MIN(category_sort_order_goal),category_goal
        `
    },

    this_year:{
        title:"3 - This Year Estimate",
        sql:matrix_query("3_this_year_sales_estimate_nonbulk",[
            {metric:"Revenue",month:this_year_revenue,total:"ROUND(SUM(sales_rev_this_year_estimate_nonbulk),0)"},
            {metric:"Units",month:this_year_units,total:"ROUND(SUM(sales_units_this_year_estimate_nonbulk),0)"},
            {metric:"Effective Price",month:this_year_price,total:"ROUND(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2)"}
        ])
    },

    next_year:{
        title:"4 - Next Year Goal",
        sql:matrix_query("4_next_year_sales_goal_nonbulk",[
            {metric:"Revenue",month:next_year_revenue,total:"ROUND(SUM(sales_rev_next_year_goal_nonbulk),2)"},
            {metric:"Units",month:next_year_units,total:"ROUND(SUM(sales_units_next_year_goal_nonbulk),0)"},
            {metric:"Effective Price",month:next_year_price,total:"ROUND(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2)"}
        ])
    },

    variance:{
        title:"5 - Variance",
        sql:matrix_query("5_variance_next_year_vs_this_year_nonbulk",[
            {
                metric:"Revenue",
                month:m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2)`,
                total:"ROUND(SUM(sales_rev_next_year_goal_nonbulk)-SUM(sales_rev_this_year_estimate_nonbulk),2)"
            },
            {
                metric:"Units",
                month:m=>`ROUND(SUM(CASE WHEN month_goal=${m} THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0)`,
                total:"ROUND(SUM(sales_units_next_year_goal_nonbulk)-SUM(sales_units_this_year_estimate_nonbulk),0)"
            },
            {
                metric:"Effective Price",
                month:m=>`ROUND((${next_year_price(m)})-(${this_year_price(m)}),2)`,
                total:`ROUND(
                    (SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0)) -
                    (SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)),2
                )`
            }
        ])
    },

    pct_variance:{
        title:"6 - % Variance",
        sql:matrix_query("6_pct_variance_next_year_vs_this_year_nonbulk",[
            {
                metric:"Revenue",
                month:m=>`ROUND((SUM(CASE WHEN month_goal=${m} THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=${m} THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1)`,
                total:"ROUND((SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_rev_this_year_estimate_nonbulk),0)-1)*100,1)"
            },
            {
                metric:"Units",
                month:m=>`ROUND((SUM(CASE WHEN month_goal=${m} THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=${m} THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1)`,
                total:"ROUND((SUM(sales_units_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)-1)*100,1)"
            },
            {
                metric:"Effective Price",
                month:m=>`ROUND(((${next_year_price(m)})/NULLIF((${this_year_price(m)}),0)-1)*100,1)`,
                total:`ROUND((
                    (SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0)) /
                    NULLIF((SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)),0)-1
                )*100,1)`
            }
        ])
    },

    price:{
        title:"7a - Effective Price",
        sql:`
            SELECT 
                type_goal,category_goal,category_sort_order_goal,
                MAX(price_this_year_actual) AS this_year_actual,
                MAX(price_this_year_effective_nonbulk) AS this_year_effective,
                MAX(price_next_year_actual) AS next_year_actual,
                MAX(price_next_year_effective_nonbulk) AS next_year_effective,
                @price_method AS price_method,
                @lever_price_pct_change AS lever_price_pct_change
            FROM sales_model_2027
            GROUP BY type_goal,category_goal,category_sort_order_goal
            ORDER BY type_goal,category_sort_order_goal,category_goal
        `
    },

    units:{
        title:"7b - Units",
        sql:`
            SELECT 
                type_goal,category_goal,category_sort_order_goal,
                ROUND(SUM(sales_units_this_year_estimate_nonbulk),0) AS this_year_units,
                ROUND(SUM(sales_units_next_year_goal_nonbulk),0) AS next_year_units,
                ROUND(SUM(sales_units_next_year_goal_nonbulk)-SUM(sales_units_this_year_estimate_nonbulk),0) AS unit_change,
                ROUND((SUM(sales_units_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)-1)*100,1) AS unit_pct_change,
                @volume_method AS volume_method,
                MAX(unit_next_year_pct_change) AS product_unit_pct_change
            FROM sales_model_2027
            GROUP BY type_goal,category_goal,category_sort_order_goal
            ORDER BY type_goal,category_sort_order_goal,category_goal
        `
    },

    revenue:{
        title:"7c - Revenue",
        sql:`
            SELECT 
                type_goal,category_goal,category_sort_order_goal,
                ROUND(SUM(sales_rev_this_year_estimate_nonbulk),2) AS this_year_revenue,
                ROUND(SUM(sales_rev_next_year_goal_nonbulk),2) AS next_year_revenue,
                ROUND(SUM(sales_rev_next_year_goal_nonbulk)-SUM(sales_rev_this_year_estimate_nonbulk),2) AS revenue_change,
                ROUND((SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_rev_this_year_estimate_nonbulk),0)-1)*100,1) AS revenue_pct_change,
                @volume_method AS volume_method,
                @price_method AS price_method,
                @lever_price_pct_change AS lever_price_pct_change
            FROM sales_model_2027
            GROUP BY type_goal,category_goal,category_sort_order_goal
            ORDER BY type_goal,category_sort_order_goal,category_goal
        `
    },

    lever_month:{
        title:"8 - Business Levers by Month",
        sql:`
            SELECT month_goal,
            FORMAT(SUM(lever_new_member_units_incremental),0) AS new_members,
            FORMAT(SUM(lever_repeat_units_incremental),0) AS repeat_members,
            FORMAT(SUM(lever_winback_units_incremental),0) AS winback,
            FORMAT(SUM(lever_mix_units_incremental),0) AS mix,
            FORMAT(SUM(lever_units_incremental),0) AS total
            FROM sales_model_2027
            GROUP BY month_goal WITH ROLLUP
            ORDER BY month_goal
        `
    },

    lever_type:{
        title:"9 - Business Levers by Type",
        sql:`
            SELECT type_goal,
            FORMAT(SUM(lever_new_member_units_incremental),0) AS new_members,
            FORMAT(SUM(lever_repeat_units_incremental),0) AS repeat_members,
            FORMAT(SUM(lever_winback_units_incremental),0) AS winback,
            FORMAT(SUM(lever_mix_units_incremental),0) AS mix,
            FORMAT(SUM(lever_units_incremental),0) AS total
            FROM sales_model_2027
            GROUP BY type_goal WITH ROLLUP
            ORDER BY type_goal
        `
    },

    redistribution:{
        title:"10 - Product Redistribution",
        sql:`
            SELECT
                category_goal,
                ROUND(SUM(units_nonbulk_next_year_base),0) AS units_before_redistribution,
                ROUND(SUM(units_nonbulk_next_year),0) AS units_after_redistribution,
                ROUND(
                    SUM(units_nonbulk_next_year)
                    - SUM(units_nonbulk_next_year_base)
                ,0) AS redistribution_unit_change,

                @discontinue_Platinum_Foundation AS discontinue_platinum_foundation,
                @discontinue_Platinum_USA AS discontinue_platinum_usa,
                @redistribute_Platinum_to_Silver_pct AS platinum_to_silver_pct,
                @redistribute_Platinum_to_Gold_pct AS platinum_to_gold_pct,
                @redistribute_Platinum_to_3_Year_pct AS platinum_to_3_year_pct

            FROM sales_model_2027
            WHERE category_goal IN (
                'Platinum - Foundation',
                'Platinum - Team USA',
                'Silver',
                'Gold',
                '3-Year'
            )
            GROUP BY category_goal

            UNION ALL

            SELECT
                'Grand Total',
                ROUND(SUM(units_nonbulk_next_year_base),0),
                ROUND(SUM(units_nonbulk_next_year),0),
                ROUND(
                    SUM(units_nonbulk_next_year)
                    - SUM(units_nonbulk_next_year_base)
                ,0),

                @discontinue_Platinum_Foundation,
                @discontinue_Platinum_USA,
                @redistribute_Platinum_to_Silver_pct,
                @redistribute_Platinum_to_Gold_pct,
                @redistribute_Platinum_to_3_Year_pct

            FROM sales_model_2027
            WHERE category_goal IN (
                'Platinum - Foundation',
                'Platinum - Team USA',
                'Silver',
                'Gold',
                '3-Year'
            )
        `
    }
};

app.get("/api/health",async(req,res)=>{
    try{
        const [rows]=await pool.query("SELECT DATABASE() AS db");
        res.json({ok:true,database:rows[0].db});
    }catch(error){
        res.status(500).json({ok:false,error:error.message});
    }
});

app.get("/api/config",async(req,res)=>{
    try{
        const variables=get_model_variables(),unit_map={};

        try{
            const [rows]=await pool.query(`
                SELECT category_goal,ROUND(SUM(sales_units_this_year_estimate_nonbulk),0) AS units
                FROM sales_model_2027
                GROUP BY category_goal
            `);
            rows.forEach(row=>unit_map[row.category_goal]=Number(row.units||0));
        }catch(error){
            console.log("Unable to load existing units:",error.message);
        }

        res.json({
            actual_through_month:Number(variables.actual_through_month||8),
            volume_method:variables.volume_method||"TOP_LEVEL",
            price_method:variables.price_method||"PRODUCT",
            lever_price_pct_change:Number(variables.lever_price_pct_change||0),

            top_level_volume:{
                new_members_base:Number(variables.lever_new_members_base||0),
                new_members_pct_change:Number(variables.lever_new_members_pct_change||0),

                repeat_one_day_base:Number(variables.lever_repeat_one_day_base||0),
                repeat_annual_base:Number(variables.lever_repeat_annual_base||0),
                repeat_members_base:Number(variables.lever_repeat_members_base||0),
                repeat_members_pct_change:Number(variables.lever_repeat_members_pct_change||0),

                winback_annual_pct:Number(variables.lever_winback_annual_pct||0.50),
                winback_one_day_pct:Number(variables.lever_winback_one_day_pct||0.50),
                winback_units_incremental:Number(variables.lever_winback_units_incremental||0),

                upgrades_base:Number(variables.lever_upgrades_base||0),
                upgrades_pct_change:Number(variables.lever_upgrades_pct_change||0),

                downgrades_base:Number(variables.lever_downgrades_base||0),
                downgrades_pct_change:Number(variables.lever_downgrades_pct_change||0),

                discontinue_platinum_foundation:Number(variables.discontinue_Platinum_Foundation||0),
                discontinue_platinum_usa:Number(variables.discontinue_Platinum_USA||0),

                redistribute_platinum_silver_pct:Number(variables.redistribute_Platinum_to_Silver_pct||0),
                redistribute_platinum_gold_pct:Number(variables.redistribute_Platinum_to_Gold_pct||0),
                redistribute_platinum_3_year_pct:Number(variables.redistribute_Platinum_to_3_Year_pct||0),
            },

            products:products.map(product=>{
                const actual_this_year=Number(variables[`${product.key}_actual_this_year`]||0);
                const effective_this_year=Number(variables[`${product.key}_effective_this_year`]||0);
                const actual_next_year=Number(variables[`${product.key}_actual_next_year`]||0);
                const growth_pct=Number(variables[`UG_${product.key}`]||0);

                return {
                    ...product,
                    actual_this_year,
                    effective_this_year,
                    actual_next_year,
                    calculated_effective_next_year:actual_this_year?actual_next_year*(effective_this_year/actual_this_year):0,
                    growth_pct,
                    this_year_units:unit_map[product.name]||0
                };
            }),

            reports:Object.entries(reports).map(([key,report])=>({key,title:report.title}))
        });

    }catch(error){
        res.status(500).json({error:error.message});
    }
});

app.post("/api/run",async(req,res)=>{
    let connection;

    try{
        const variables=req.body.variables||{};
        let sql=fs.readFileSync(model_path,"utf8");

        for(const [key,value] of Object.entries(variables))
            sql=replace_variable(sql,key,value);

        connection=await pool.getConnection();
        await connection.query(sql);

        last_variables={...get_model_variables(),...variables};

        const [rows]=await connection.query(`
            SELECT
            ROUND(SUM(sales_rev_this_year_estimate_nonbulk),2) AS this_year_revenue,
            ROUND(SUM(sales_rev_next_year_goal_nonbulk),2) AS next_year_revenue,
            ROUND(SUM(sales_units_this_year_estimate_nonbulk),0) AS this_year_units,
            ROUND(SUM(sales_units_next_year_goal_nonbulk),0) AS next_year_units
            FROM sales_model_2027
        `);

        const summary=rows[0];
        summary.revenue_pct_change=summary.this_year_revenue?(summary.next_year_revenue/summary.this_year_revenue-1)*100:0;
        summary.units_pct_change=summary.this_year_units?(summary.next_year_units/summary.this_year_units-1)*100:0;

        res.json({ok:true,summary});

    }catch(error){
        console.error(error);
        res.status(500).json({ok:false,error:error.message});
    }finally{
        if(connection) connection.release();
    }
});

app.get("/api/results/:type",async(req,res)=>{
    const report=reports[req.params.type];
    if(!report) return res.status(400).json({error:"Unknown report"});

    let connection;

    try{
        connection=await pool.getConnection();
        await set_variables(connection,last_variables);
        const [rows]=await connection.query(report.sql);
        res.json(rows);
    }catch(error){
        res.status(500).json({error:error.message});
    }finally{
        if(connection) connection.release();
    }
});

app.get("/api/versions",async(req,res)=>{
    try{
        const [rows]=await pool.query(`
            SELECT id,version_name,model_name,user_name,assumptions_json,is_default,created_at
            FROM sales_model_2027_versions
            ORDER BY id DESC
        `);
        res.json(rows);
    }catch(error){res.status(500).json({error:error.message});}
});

app.post("/api/versions",async(req,res)=>{
    const connection=await pool.getConnection();
    try{
        const user_name=String(req.body.user_name||"").trim().toLowerCase().replace(/[^a-z0-9_-]/g,"");
        if(!user_name)return res.status(400).json({error:"User name is required."});

        const model_name=String(req.body.model_name||"").trim().toLowerCase().replace(/[^a-z0-9]+/g,"_").replace(/^_+|_+$/g,"");

        const assumptions=req.body.assumptions||{},is_default=req.body.is_default?1:0;
        if(!model_name)return res.status(400).json({error:"Model name is required."});

        if(is_default)await connection.query(`UPDATE sales_model_2027_versions SET is_default=0`);

        const [result]=await connection.query(`
            INSERT INTO sales_model_2027_versions
            (model_name,user_name,assumptions_json,is_default)
            VALUES (?,?,?,?)
        `,[model_name,user_name,JSON.stringify(assumptions),is_default]);

        const id=result.insertId,now=new Date();
        const mm=String(now.getMonth()+1).padStart(2,"0"),dd=String(now.getDate()).padStart(2,"0"),yy=String(now.getFullYear()).slice(-2);
        const version_name=`v${id}_${mm}${dd}${yy}_${user_name}_${model_name}`;

        await connection.query(`UPDATE sales_model_2027_versions SET version_name=? WHERE id=?`,[version_name,id]);
        await connection.commit();

        res.json({ok:true,id,version_name,is_default});
    }catch(error){
        await connection.rollback();
        res.status(500).json({error:error.message});
    }finally{connection.release();}
});

app.get("/api/versions/:id",async(req,res)=>{
    try{
        const [rows]=await pool.query(`SELECT * FROM sales_model_2027_versions WHERE id=?`,[req.params.id]);
        if(!rows.length)return res.status(404).json({error:"Version not found."});
        res.json(rows[0]);
    }catch(error){res.status(500).json({error:error.message});}
});

app.delete("/api/versions/:id",async(req,res)=>{
    try{
        const [rows]=await pool.query(`
            SELECT id,version_name,is_default
            FROM sales_model_2027_versions
            WHERE id=?
        `,[req.params.id]);

        if(!rows.length)return res.status(404).json({ok:false,error:"Version not found."});
        if(Number(rows[0].is_default)===1)
            return res.status(400).json({ok:false,error:"Default model cannot be deleted. Set another model as default first."});

        await pool.query(`DELETE FROM sales_model_2027_versions WHERE id=?`,[req.params.id]);
        res.json({ok:true,version_name:rows[0].version_name});
    }catch(error){
        res.status(500).json({ok:false,error:error.message});
    }
});

app.post("/api/versions/:id/default",async(req,res)=>{
    const connection=await pool.getConnection();
    try{
        await connection.beginTransaction();
        await connection.query(`UPDATE sales_model_2027_versions SET is_default=0`);
        await connection.query(`UPDATE sales_model_2027_versions SET is_default=1 WHERE id=?`,[req.params.id]);
        await connection.commit();
        res.json({ok:true});
    }catch(error){
        await connection.rollback();
        res.status(500).json({error:error.message});
    }finally{connection.release();}
});

const build_assumption_rows=variables=>[
    {section:"model",type:"",category:"",assumption:"actual_through_month",value:variables.actual_through_month},
    {section:"model",type:"",category:"",assumption:"volume_method",value:variables.volume_method},
    {section:"model",type:"",category:"",assumption:"price_method",value:variables.price_method},
    {section:"top_level",type:"",category:"",assumption:"lever_new_members_base",value:variables.lever_new_members_base},
    {section:"top_level",type:"",category:"",assumption:"lever_new_members_pct_change",value:variables.lever_new_members_pct_change},
    {section:"top_level",type:"",category:"",assumption:"lever_repeat_one_day_base",value:variables.lever_repeat_one_day_base},
    {section:"top_level",type:"",category:"",assumption:"lever_repeat_annual_base",value:variables.lever_repeat_annual_base},
    {section:"top_level",type:"",category:"",assumption:"lever_repeat_members_base",value:variables.lever_repeat_members_base},
    {section:"top_level",type:"",category:"",assumption:"lever_repeat_members_pct_change",value:variables.lever_repeat_members_pct_change},
    {section:"top_level",type:"",category:"",assumption:"lever_winback_units_incremental",value:variables.lever_winback_units_incremental},
    {section:"top_level",type:"",category:"",assumption:"lever_winback_one_day_pct",value:variables.lever_winback_one_day_pct},
    {section:"top_level",type:"",category:"",assumption:"lever_winback_annual_pct",value:variables.lever_winback_annual_pct},
    {section:"top_level",type:"",category:"",assumption:"lever_upgrades_base",value:variables.lever_upgrades_base},
    {section:"top_level",type:"",category:"",assumption:"lever_upgrades_pct_change",value:variables.lever_upgrades_pct_change},
    {section:"top_level",type:"",category:"",assumption:"lever_downgrades_base",value:variables.lever_downgrades_base},
    {section:"top_level",type:"",category:"",assumption:"lever_downgrades_pct_change",value:variables.lever_downgrades_pct_change},
    {section:"price",type:"",category:"",assumption:"lever_price_pct_change",value:variables.lever_price_pct_change},
    {section:"redistribution",type:"adult_annual",category:"Platinum - Foundation",assumption:"discontinue",value:variables.discontinue_Platinum_Foundation},
    {section:"redistribution",type:"adult_annual",category:"Platinum - Team USA",assumption:"discontinue",value:variables.discontinue_Platinum_USA},
    {section:"redistribution",type:"adult_annual",category:"Silver",assumption:"redistribution_pct",value:variables.redistribute_Platinum_to_Silver_pct},
    {section:"redistribution",type:"adult_annual",category:"Gold",assumption:"redistribution_pct",value:variables.redistribute_Platinum_to_Gold_pct},
    {section:"redistribution",type:"adult_annual",category:"3-Year",assumption:"redistribution_pct",value:variables.redistribute_Platinum_to_3_Year_pct},
    ...products.flatMap(product=>[
        {section:"product_volume",type:product.type,category:product.name,assumption:"growth_pct",value:variables[`UG_${product.key}`]},
        {section:"product_price",type:product.type,category:product.name,assumption:"this_year_price",value:variables[`${product.key}_actual_this_year`]},
        {section:"product_price",type:product.type,category:product.name,assumption:"this_year_effective",value:variables[`${product.key}_effective_this_year`]},
        {section:"product_price",type:product.type,category:product.name,assumption:"next_year_price",value:variables[`${product.key}_actual_next_year`]}
    ])
];

app.get("/api/export",async(req,res)=>{
    let connection;

    try{
        connection=await pool.getConnection();
        await set_variables(connection,last_variables);

        const workbook=new excel_js.Workbook();

        const assumptions=workbook.addWorksheet("assumptions");
        assumptions.columns=[
            {header:"section",key:"section",width:20},
            {header:"type",key:"type",width:18},
            {header:"category",key:"category",width:32},
            {header:"assumption",key:"assumption",width:36},
            {header:"value",key:"value",width:18}
        ];
        build_assumption_rows(last_variables).forEach(row=>assumptions.addRow(row));
        assumptions.views=[{state:"frozen",ySplit:1}];
        assumptions.autoFilter={from:"A1",to:"E1"};

        for(const [key,report] of Object.entries(reports)){
            const [rows]=await connection.query(report.sql);
            const worksheet=workbook.addWorksheet(key.substring(0,31));

            if(!rows.length) continue;

            worksheet.columns=Object.keys(rows[0]).map(column=>({
                header:column,key:column,width:Math.max(14,Math.min(35,column.length+2))
            }));

            rows.forEach(row=>worksheet.addRow(row));
            worksheet.views=[{state:"frozen",ySplit:1}];
            worksheet.autoFilter={from:"A1",to:{row:1,column:Object.keys(rows[0]).length}};
        }

        res.setHeader("Content-Type","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        res.setHeader("Content-Disposition",'attachment; filename="sales_model_2027.xlsx"');

        await workbook.xlsx.write(res);
        res.end();

    }catch(error){
        res.status(500).send(error.message);
    }finally{
        if(connection) connection.release();
    }
});

app.listen(port,()=>console.log(`USAT Sales Model: http://localhost:${port}`));