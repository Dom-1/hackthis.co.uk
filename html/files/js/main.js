$(function() {

    function time_since(oldD) {
        var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

        newD = new Date();
        diff = Math.round((newD.getTime() - oldD.getTime()) / 1000);
        
        isSameDay = (oldD.getDate() == newD.getDate() 
                     && oldD.getMonth() == newD.getMonth()
                     && oldD.getFullYear() == newD.getFullYear());

        if (isSameDay) {
            if (diff < 60) {
                return "secs ago";
            } else if (diff < 3600) {
                var n = Math.floor(diff/60);
                return n + " min" + (n==1?'':'s') + " ago";
            } else {
                var n = Math.floor(diff/3600);
                return n + " hour" + (n==1?'':'s') + " ago";
            }
        } else {
            newD.setDate(newD.getDate() - 1);

            isYesterday = (oldD.getDate() == newD.getDate() 
                         && oldD.getMonth() == newD.getMonth()
                         && oldD.getFullYear() == newD.getFullYear());

            if (isYesterday) {
                return "Yesterday";
            } else {
                newD.setDate(newD.getDate() - 6);
                if (oldD > newD)
                    return days[oldD.getDay()];
                else
                    return (oldD.getDate()+1) + "/" + (oldD.getMonth()+1);
            }
        }
    }

    var notificationsTmpl = '<tmpl>'+
                           '{{if seen == 0}}'+
                           '    <li class="new">'+
                           '{{else}}'+
                           '    <li>'+
                           '{{/if}}'+
                           '        <time datetime="${timestamp}">${time}</time>'+
                           '{{if username}}'+
                           '        <a href="/user/${username}">'+
                           '            <img class="left" width="28" height="28" src="https://www.hackthis.co.uk/users/images/28/1:1/${img}.jpg"/>'+
                           '        </a>'+
                           '{{/if}}'+
                           '{{if pm_id}}'+
                           '            <a class="strong" href="/inbox/${pm_id}">${title}<a/><br/>'+
                           '            ${message}'+
                           '{{else}}'+
                           '    {{if type == 1}}'+
                           '            <a href="/user/${username}">${username}<a/> sent you a friend request'+
                           '            <a href="#">Accept</a> | <a href="#">Decline</a>'+
                           '    {{else type == 2}}'+
                           '            <a href="/user/${username}">${username}<a/> accepted your friend request<br/>'+
                           '    {{else type == 3}}'+
                           '            You have been awarded <a href="/medals/"><div class="medal medal-gold">visit</div></a><br/>'+
                           '    {{/if}}'+
                           '{{/if}}'+
                           '    </li>'+
                           '</tmpl>';

    $('.nav-extra').bind('click', function(e) {
        e.preventDefault();
        e.stopPropagation();

        var uri = '/files/ajax/notifications.php'
        if ($(this).hasClass('nav-extra-pm')) {
            uri += '?pm';
        } else if ($(this).hasClass('nav-extra-events')) {
            uri += '?events';
        } else {
            return false;
        }

        $.getJSON(uri, function(data) {
            var html = '';
            $.each(data, function(index, item) {
                var d = new Date(item.timestamp*1000);
                item.time = time_since(d);
            });

            html = $(notificationsTmpl).tmpl(data);
            $('#nav-extra-dropdown').html(html).slideDown(200);
        });

        $('.nav-extra').parent().removeClass('active');
        $(this).parent().removeClass('alert').addClass('active');
        //$('#nav-extra-dropdown').html('<img src="/files/images/icons/loading_bg.gif"/>').show();

        $(document).bind('click.extra-hide', function(e){
           if ($(e.target).closest('#nav-extra-dropdown').length != 0 && $(e.target).not('.nav-extra')) return false;
           $('#nav-extra-dropdown').slideUp(200);
           $('.nav-extra').parent().removeClass('active');
           $(document).unbind('click.extra-hide');
        });
    });
});