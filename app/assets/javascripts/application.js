// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require materialize-sprockets
//= require highcharts/highcharts-more
//= require jquery_ujs
//= require turbolinks
//= require_tree .



$(function () {
    var data_ranges = $('.totals').data('ranges')
    var data_most_recent = $('.totals').data('mostRecent')
    var max_total = $('.totals').data('max')
    var ranges = data_ranges,
        most_recent = data_most_recent;

var chart = new Highcharts.Chart({
                chart: {
                    renderTo: 'container'
                },
        title: {
            text: "Check Totals for the past five Sunday's"
        },

        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
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

        series: [{
            name: 'Most Recent Sunday',
            data: most_recent,
            zIndex: 1,
            marker: {
                fillColor: 'white',
                lineWidth: 2,
                lineColor: Highcharts.getOptions().colors[0]
            }
        }, {
            name: 'Range',
            data: ranges,
            type: 'arearange',
            lineWidth: 0,
            linkedTo: ':previous',
            color: Highcharts.getOptions().colors[0],
            fillOpacity: 0.3,
            zIndex: 0
        }]
    });
});