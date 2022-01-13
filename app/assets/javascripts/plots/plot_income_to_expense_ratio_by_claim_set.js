// [
//    {
//       "account_code":"00333",
//       "claim_set_code":"CBT:06",
//       "done":"50070",
//       "total_inc":"65460.00",
//       "total_exp":"23515.98",
//       "total_net":"41944.02",
//       "unit_inc":"1.30737",
//       "unit_exp":"0.46966",
//       "unit_net":"0.83771",
//       "unit_net_pct":"83.771",
//    }
// ]

function plotIncomeToExpenseRatioByClaimSet(url) {

    d3.json(url, function (data) {
        var x = ['x'];
        var inc_exp_ratio = ['inc_exp_ratio'];

        data.forEach(function (d, i) {
            console.log('++++');
            console.log(d);

            x.push(d.claim_set_name);
            inc_exp_ratio.push(+d.inc_exp_ratio);
        });

        c3.generate({
            bindto: '#plot_income_to_expense_ratio_by_claim_set_container',
            data: {
                x: 'x',
                columns: [
                    x,
                    inc_exp_ratio
                ],
                type: 'bar'
            },
            axis: {
                x: {
                    type: 'category' // this needed to load string x value
                }
            },
            zoom: {
                enabled: true,
                rescale: true
            }
        });

    });
}