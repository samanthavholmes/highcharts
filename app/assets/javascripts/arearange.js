$(document).ready($(function () {
    if (document.getElementById('arearange')) {
    var ranges = $('.totals').data('ranges')
    var most_recent = $('.totals').data('mostRecent')
    var max_total = $('.totals').data('max')
    var timeframe = $('.totals').data('timeframe')
    var averages = $('.totals').data('averages')

    if (timeframe == "Week") {
               var title = "Check Totals for the Past " + timeframe
            }
            else {
                var title = "Check Totals for the Past Five " + timeframe + "'s"
            };

    var arearange = new Highcharts.Chart({
                chart: {
                    renderTo: 'arearange'
                },

        title: {
            text: title
        },

        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
                day: '%m/%d',
                minute: '%I:%M PM'
            }
        },

        yAxis: {
            min: 0, max: max_total + 5,
            title: {
                text: "Check Total ($)"
            }
        },

        tooltip: {
            crosshairs: true,
            shared: true,
            valuePrefix: '$'
        },

        series: [
        {
            name: 'Range',
            data: ranges,
            type: 'arearange',
            lineWidth: 0,
            linkedTo: ':previous',
            color: Highcharts.getOptions().colors[0],
            fillOpacity: 0.3,
            zIndex: 0
        },
        {
            name: "Most Recent " + timeframe,
            data: most_recent,
            zIndex: 1,
            marker: {
                fillColor: 'white',
                lineWidth: 2,
                lineColor: Highcharts.getOptions().colors[0]
            }
        },
        {
            name: "Average " + timeframe,
            data: averages,
            zIndex: 1,
            marker: {
                fillColor: 'black',
                lineWidth: 2,
                lineColor: Highcharts.getOptions().colors[0]
            }
        }]
    });
}
}));