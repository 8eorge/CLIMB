$(document).ready(function(){
    window.addEventListener('message', function(event) {
        var i = event.data
        switch(i.action) {
            case 'openMainMenu':
                $('.climb-cont').fadeIn(500)
            break;
            case 'hideMainMenu':
                $('.climb-cont').fadeOut(500)
            break;
        }
    });
    $('#store').click(function() {

    })
    $('#settings').click(function() {

    })
    $('#quit').click(function() {
 
    })
    $('#multiplayer').click(function() {
	$.post(`https://${GetParentResourceName()}/climb-home`, JSON.stringify({action: "multiplayer"}));
    })
    $('#privatelobby').click(function() {
    $.post(`https://${GetParentResourceName()}/climb-home`, JSON.stringify({action: "privatelobby"}));
    })
    $('#customisation').click(function() {
        
    })
});

