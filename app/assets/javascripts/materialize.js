$(document).ready(function() {
  $('select').material_select();
  $("select[required]").css({display: "inline", height: 0, padding: 0, width: 0});
  $('.datepicker').pickadate({
    selectMonths: true, // Creates a dropdown to control month
    selectYears: 3, // Creates a dropdown of 15 years to control year
  });
});


