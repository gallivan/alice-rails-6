function plotWhoWhatWhen(showWho, url, params) {

    'use strict';

// http://www.codeproject.com/Articles/693841/Making-Dashboards-with-Dc-js-Part-1

    console.log('begun at ' + Date());

    $("#reset-button>input:last-of-type").bind('click', function () {
        console.log("here")
        dc.filterAll();
        dc.renderAll();
    });

    var rowChartWidth = 200;
    var rowChartHeight = 750;

    var barChartWidth = 500;
    var barChartHeight = rowChartHeight / 5;

    var transitionDuration = 1500;

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

    function rowChart(div, dimension, group) {
        var chart = dc.rowChart(div);
        chart
            .width(rowChartWidth)
            .height(rowChartHeight)
            .elasticX(true)
            .transitionDuration(transitionDuration)
            .margins({top: 5, right: 50, bottom: 60, left: 30})
            .dimension(dimension)
            .group(group);
        chart.on("renderlet", function () {
            d3.select(div).selectAll(".tick text").attr('transform', "translate(-30,25) rotate(-90)");
        });
    }

    function barChart(div, dimension, group, minDate, maxDate, label) {
        var chart = dc.barChart(div);
        chart
            .width(barChartWidth)
            .height(barChartHeight)
            .elasticY(true)
            .elasticX(true)
            .transitionDuration(transitionDuration)
            .margins({top: 5, right: 60, bottom: 60, left: 60})
            .yAxisLabel(label)
            .dimension(dimension)
            .centerBar(true)
            .gap(1)
            .group(group)
            .x(d3.scaleTime().domain([minDate, maxDate]));
        chart.on("renderlet", function (chart) {
            chart.selectAll("g.axis.x text").attr('transform', "translate(0,25) rotate(-65)");
        });
    }

    $("#dc-chart-exch").hide();
    $("#dc-chart-acct-nets").hide();
    $("#dc-chart-name-nets").hide();

    $("#dc-chart-bar-done-totals").hide();
    $("#dc-chart-bar-flow-totals").hide();
    $("#dc-chart-bar-cost-totals").hide();
    $("#dc-chart-bar-nets-totals").hide();
    $("#dc-chart-bar-rats-totals").hide();

    $("#message").html('Retrieving data....');


    var plotGraphs = function(error, data) {

        $("#message").html('Processing data....');

        var dateFormatSpecifier = "%Y-%m-%d";
        var dateFormatParser = d3.timeParse(dateFormatSpecifier);
        var formatDate = d3.timeFormat("%Y-%m-%d");

        data.forEach(function (d, i) {
            var res = d.claim_set_code.split(':');
            d.acct = d.account_code;
            d.post = dateFormatParser(d.posted_on);
            d.exch = res[0];
            // d.name = res[1]; // THIS IS REALLY THE CONTRACT CODE - NOT THE NAME
            d.name = d.claim_set_name; // THIS IS REALLY THE CONTRACT CODE - NOT THE NAME
            d.done = +d.done;
            d.flow = +d.inc;
            d.cost = +d.exp;
            d.nets = +d.net;
            d.rats = +d.inc / Math.abs(+d.exp);

        });

        //print_filter(data);

        var facts = crossfilter(data);

        var acctDimension = facts.dimension(function (d) {
            return d.acct;
        });
        var dateDimension = facts.dimension(function (d) {
            return d.post;
        });
        var exchDimension = facts.dimension(function (d) {
            return d.exch;
        });
        var nameDimension = facts.dimension(function (d) {
            return d.name;
        });

        print_filter(dateDimension.top(5));
        print_filter(dateDimension.bottom(5));

        console.log("Length of data: " + data.length);

        // Sums
        console.log("A");
        var doneTotals = dateDimension.group().reduceSum(function (d) {
            return d.done;
        });
        var flowTotals = dateDimension.group().reduceSum(function (d) {
            return d.flow;
        });
        var costTotals = dateDimension.group().reduceSum(function (d) {
            return d.cost;
        });
        var netsTotals = dateDimension.group().reduceSum(function (d) {
            return d.nets;
        });
        var ratsTotals = dateDimension.group().reduceSum(function (d) {
            return d.rats;
        });
        var exchTotals = exchDimension.group().reduceSum(function (d) {
            return d.done;
        });
        // NETS
        var acctNetsTotals = acctDimension.group().reduceSum(function (d) {
            return d.nets;
        });
        var nameNetsTotals = nameDimension.group().reduceSum(function (d) {
            return d.nets;
        });
        console.log("Z");

        var minDate = dateDimension.bottom(1)[0].post;
        var maxDate = dateDimension.top(1)[0].post;

        console.log(minDate);
        console.log(maxDate);

        console.log(doneTotals);

        rowChart("#dc-chart-exch", exchDimension, exchTotals);
        console.log(showWho);
        if (showWho) {
            rowChart("#dc-chart-acct-nets", acctDimension, acctNetsTotals);
        }
        rowChart("#dc-chart-name-nets", nameDimension, nameNetsTotals);

        barChart("#dc-chart-bar-done-totals", dateDimension, doneTotals, minDate, maxDate, "Done");
        barChart("#dc-chart-bar-flow-totals", dateDimension, flowTotals, minDate, maxDate, "Income");
        barChart("#dc-chart-bar-cost-totals", dateDimension, costTotals, minDate, maxDate, "Expemse");
        barChart("#dc-chart-bar-nets-totals", dateDimension, netsTotals, minDate, maxDate, "Net");
        barChart("#dc-chart-bar-rats-totals", dateDimension, ratsTotals, minDate, maxDate, "Inc/Exp Ratio");

        $("#message").html('Done.').fadeOut();
        $("#timestamp").show();
        $("#plot").show();

        // row plots

        $("#dc-chart-exch").show();
        if (showWho) {
            $("#dc-chart-acct-nets").show();
        }
        $("#dc-chart-name-nets").show();

        // pin plots

        $("#dc-chart-bar-done-totals").show();
        $("#dc-chart-bar-flow-totals").show();
        $("#dc-chart-bar-cost-totals").show();
        $("#dc-chart-bar-nets-totals").show();
        $("#dc-chart-bar-rats-totals").show();

        dc.renderAll();

        console.log('ended at ' + Date());
    };

    var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    var token_name = document.querySelector('meta[name="csrf-param"]').getAttribute('content');
    var p1 = JSON.stringify(params);
    console.log(p1);
    d3.json(url)
        .header("Content-Type", "application/json")
        .header(token_name, token)
        .post(p1, plotGraphs);

}