const pool = require("../config/database");

const getSalesDashboardStats = async (salesRepId) => {

    console.log("📊 Fetching stats for sales rep:", salesRepId);

    // ✅ 1. Trial Accounts
    const trialResult = await pool.query(
        `
        SELECT COUNT(*) AS trial_count
        FROM customers
        WHERE sales_rep_id = $1
        AND current_stage = 'Trial';
        `,
        [salesRepId]
    );

    const trialAccounts = parseInt(trialResult.rows[0].trial_count) || 0;

    // ✅ 2. Converted Accounts
    const convertedResult = await pool.query(
        `
        SELECT COUNT(*) AS converted_count
        FROM customers
        WHERE sales_rep_id = $1
        AND current_stage IN ('Closed Won', 'Subscribed');
        `,
        [salesRepId]
    );

    const convertedAccounts = parseInt(convertedResult.rows[0].converted_count) || 0;

    // ✅ 3. Total Assigned Customers
    const totalResult = await pool.query(
        `
        SELECT COUNT(*) AS total_count
        FROM customers
        WHERE sales_rep_id = $1;
        `,
        [salesRepId]
    );

    const totalCustomers = parseInt(totalResult.rows[0].total_count) || 0;

    // ✅ 4. Conversion Rate
    let conversionRate = 0;
    if (totalCustomers > 0) {
        conversionRate = Math.round((convertedAccounts / totalCustomers) * 100);
    }

    // ✅ 5. Scheduled Meetings (Demo + Negotiation)
    const meetingsResult = await pool.query(
        `
        SELECT COUNT(*) AS meeting_count
        FROM (
            SELECT db.demo_id
            FROM demo_bookings db
            LEFT JOIN customers c ON db.customer_id = c.customer_id
            WHERE (db.sales_rep_id = $1 OR c.sales_rep_id = $1)
            AND (db.status IS NULL OR db.status ILIKE 'scheduled%')

            UNION ALL

            SELECT nm.negotiation_id
            FROM negotiation_meetings nm
            LEFT JOIN customers c ON nm.customer_id = c.customer_id
            WHERE (nm.sales_rep_id = $1 OR c.sales_rep_id = $1)
            AND (nm.status IS NULL OR nm.status ILIKE 'scheduled%')
        ) AS combined;
        `,
        [salesRepId]
    );

    const meetingsToday = parseInt(meetingsResult.rows[0].meeting_count) || 0;

    // ✅ 6. Quota Progress (Monthly quota target: 2 closed deals)
    const monthlyQuota = 2;
    const quotaProgress = Math.min(
        Math.round((convertedAccounts / monthlyQuota) * 100),
        100
    );

    return {
        trialAccounts,
        conversionRate,
        quotaProgress,
        meetingsToday
    };
};

module.exports = {
    getSalesDashboardStats
};
