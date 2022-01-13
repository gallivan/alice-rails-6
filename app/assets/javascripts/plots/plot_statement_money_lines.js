function plotStatementMoneyLines(url) {
    var format_number = d3.format(" >+12.2f");
    var dateFormatSpecifier = "%Y-%m-%d";
    var dateFormatParser = d3.timeParse(dateFormatSpecifier);

    d3.json(url, function (data) {
        x = ['x'];
        charges = ['charges'];
        pnl_futures = ['pnl_futures'];
        open_trade_equity = ['open_trade_equity'];
        net_liquidating_balance = ['net_liquidating_balance'];

        data.forEach(function (d, i) {
            console.log('++++');
            console.log(d);

            x.push(dateFormatParser(d.stated_on));
            charges.push(+d.charges);
            pnl_futures.push(+d.pnl_futures);
            open_trade_equity.push(+d.open_trade_equity);
            net_liquidating_balance.push(+d.net_liquidating_balance);
        });

        c3.generate({
            bindto: '#statement_money_lines_plot_container',
            data: {
                x: 'x',
                columns: [
                    x,
                    charges,
                    pnl_futures,
                    open_trade_equity,
                    net_liquidating_balance
                ],
                axes: {
                    net_liquidating_balance: 'y2'
                },
                type: 'bar',
                types: {
                    net_liquidating_balance: 'spline'
                },
                groups: [
                    ['charges', 'pnl_futures', 'open_trade_equity']
                ]
            },
            axis: {
                x: {
                    type: 'timeseries',
                    tick: {
                        format: '%m/%d'
                    }
                },
                y: {
                    show: true,
                    tick: {
                        format: function (x) {
                            return format_number(x);
                        }
                    }
                },
                y2: {
                    show: true,
                    label: 'net_liquidating_balance',
                    tick: {
                        format: function (x) {
                            return format_number(x);
                        }
                    }
                }
            },
            point: {
                r: 3
            }
        });

    });
}