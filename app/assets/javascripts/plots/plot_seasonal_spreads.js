function plotSeasonalSpreads(url) {
    'use strict';
    console.log('begun at ' + Date());
    console.log(url);

    $("#reset-button").hide();

    var dateFormatSpecifier = "%Y-%m-%d";
    var dateFormatParser = d3.timeParse(dateFormatSpecifier);

    var formatDate = d3.timeFormat("%Y-%m-%d");
    var formatFloat = d3.format(" >+12.3f");
    var formatInteger = d3.format(" >12");

    var lineChartWidth = 1150;
    var lineChartHeight = 400;

    var pinsChartWidth = lineChartWidth;
    var pinsChartHeight = 200;

    // var dataTableWidth = 1150;
    // var dataTableHeight = 600;

    var transitionDuration = 1500;

    var DEFAULT_TABLE_SIZE = 10000;

    function print_filter(filter) {
        var f = eval(filter);
        if (typeof(f.length) != "undefined") {
        } else {
        }
        if (typeof(f.top) != "undefined") {
            f = f.top(Infinity);
        } else {
        }
        if (typeof(f.dimension) != "undefined") {
            f = f.dimension(function (d) {
                return "";
            }).top(Infinity);
        } else {
        }
        console.log(filter + "(" + f.length + ") = " + JSON.stringify(f).replace("[", "[\n\t").replace(/}\,/g, "},\n\t").replace("]", "\n]"));
    }

    function lineChart(div, dimension, group, minDate, maxDate, label) {
        console.log(group);
        var chart = dc.lineChart(div);
        chart
            .width(lineChartWidth)
            .height(lineChartHeight)
            .elasticY(true)
            .elasticX(true)
            .transitionDuration(transitionDuration)
            .margins({top: 5, right: 50, bottom: 60, left: 50})
            .yAxisLabel(label)
            .dimension(dimension)
            .group(group)
            .x(d3.scaleTime().domain([minDate, maxDate]));
    }

    function pinsChart(div, dimension, group, minDate, maxDate, label) {
        var chart = dc.barChart(div);
        chart
            .dimension(dimension)
            .group(group)
            .width(pinsChartWidth)
            .height(pinsChartHeight)
            .elasticY(true)
            .elasticX(true)
            .transitionDuration(transitionDuration)
            .margins({top: 5, right: 50, bottom: 60, left: 50})
            .yAxisLabel(label)
            .centerBar(true)
            .gap(1)
            .x(d3.scaleTime().domain([minDate, maxDate]));
    }

    function dataTable(div, dimension) {
        console.log(dimension);
        var table = dc.dataTable(div);
        table
            .dimension(dimension)
            .group(function (d) {
                return d.code;
            })
            .columns([
                function (d) {
                    return formatDate(d.posted_on);
                },
                function (d) {
                    return formatFloat(d.open);
                },
                function (d) {
                    return formatFloat(d.high);
                },
                function (d) {
                    return formatFloat(d.low);
                },
                function (d) {
                    return formatFloat(d.mark);
                },
                function (d) {
                    return formatInteger(d.volume);
                }
            ])
            .size(DEFAULT_TABLE_SIZE)
            .sortBy(function (d) {
                return d.posted_on;
            })
            .order(d3.ascending)
    }

    document.getElementById("reset-button").onclick = function () {
        dc.filterAll();
        dc.renderAll();
    };

    $("#message").html('Retrieving data....');

    d3.json(url, function (data) {
        // data.forEach(function (d, i) {
        //     console.log(d);
        // });

        $("#message").html('Processing data....');

        data.forEach(function (d, i) {
            console.log(d);
            d.posted_on = dateFormatParser(d.posted_on);
            d.open = +d.open;
            d.high = +d.high;
            d.low = +d.low;
            d.mark = +d.mark;
            d.volume = +d.volume;
        });

        var facts = crossfilter(data);
        var dateDimension = facts.dimension(function (d) {
            return d.posted_on;
        });
        var marks = dateDimension.group().reduceSum(function (d) {
            return d.mark;
        });
        var pins = dateDimension.group().reduceSum(function (d) {
            return d.volume;
        });
        var minDate = dateDimension.bottom(1)[0].posted_on;
        var maxDate = dateDimension.top(1)[0].posted_on;

        console.log(minDate);
        console.log(maxDate);

        print_filter(dateDimension.top(3));
        print_filter(dateDimension.bottom(3));

        console.log("Length of data: " + data.length);

        lineChart("#dc-line-chart", dateDimension, marks, minDate, maxDate, "Marks");
        pinsChart("#dc-pins-chart", dateDimension, pins, minDate, maxDate, "Volumes");
        dataTable("#dc-data-table", dateDimension, marks);

        dc.renderAll();

        $("#message").html('Done.').fadeOut();
        $("#reset-button").show();
    });

    console.log('ended at ' + Date());
}
