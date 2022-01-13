function plotSeasonalSpreadsOverview(url) {
    console.log(url);

    $("#message").html('Retrieving data....');

    d3.json(url, function (data) {
        // console.log(typeof(data));
        // console.log(data);

        tags = data['tags'];
        xnys = data['data'];

        $("#message").html('Processing data....');

        tags.forEach(function (tag, idx) {
            var div_id = tag;
            var div_str = '<div id=DIV_ID></div>'.replace('DIV_ID', div_id);

            var btn_id = tag + '_btn';
            var btn_str = '<div id=DIV_ID></div>'.replace('DIV_ID', btn_id);

            $('#plot-wrapper').append(btn_str).append(div_str);

            document.getElementById(div_id).innerHTML += tag + '<br>';
            var plot_container = document.getElementById(div_id);

            xnys[idx]['x'].unshift('x');
            xnys[idx]['y'].unshift(tag);

            x_data = xnys[idx]['x'];
            y_data = xnys[idx]['y'];

            document.getElementById(btn_id).innerHTML += '<a class="btn btn-default" href="/view_point/seasonal_spreads?claim_set_code=' + tag + '">' + tag + '</a>';

            c3.generate({
                bindto: plot_container,
                data: {
                    x: 'x',
                    columns: [x_data, y_data],
                    type: 'spline'
                },
                point: {
                    show: false
                },
                axis: {
                    x: {
                        type: 'timeseries',
                        tick: {
                            format: '%Y-%m-%d'
                        }
                    }
                }
            });
        });
        $("#message").html('Done.').fadeOut();
    });
}

//CBT:CH09-CBT:CN09