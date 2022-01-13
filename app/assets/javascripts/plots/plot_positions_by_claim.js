function plotPositionsByClaim(url, container) {

    d3.json(url, function (data) {
        var x = ['x'];
        var bot = ['bot'];
        var sld = ['sld'];
        var net = ['net'];

        data.forEach(function (d, i) {
            console.log('++++');
            console.log(d);
            // x.push(d.claim_code);
            x.push(d.claim_name);
            bot.push(+d.bot);
            sld.push(+d.sld * -1);
            net.push(+d.net);
        });

        c3.generate({
            bindto: container,
            data: {
                x: 'x',
                columns: [
                    x,
                    bot,
                    sld,
                    net
                ],
                type: 'scatter'
            },
            axis: {
                x: {
                    type: 'category',
                    rotate: 90,
                    multiline: false,
                    height: 100,
                    show: true
                }
            },
            grid: {
                y: {
                    lines: [{value: 0}]
                }
            },
            point: {
                r: 5
            },
            zoom: {
                enabled: true,
                rescale: true
            }
        });

    });

}