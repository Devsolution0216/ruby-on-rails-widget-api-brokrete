// app/views/widgets/widget.js
var MyWidgetJS = {
    getScript: function(url, success) {
        var done, head, script;
        script = document.createElement('script');
        script.src = url;
        head = document.getElementsByTagName('head')[0];
        done = false;
        script.onload = script.onreadystatechange = function() {
            if (!done && (!this.readyState || this.readyState === 'loaded' || this.readyState === 'complete')) {
                done = true;
                success();
                script.onload = script.onreadystatechange = null;
                return head.removeChild(script);
            }
        };
        return head.appendChild(script);
    },
    load: function() {
        var $widget = $('#brokrete-widget');
        var $_token = $('#brokrete-widget').attr('_token');
        var $_url = $('#brokrete-widget').attr('_url');
        $.ajax({
            url: $_url + "/brokrete_widget",
            type: "get",
            dataType: 'html',
            data: {
                _token: $_token
            },
            success: function(data) {
                let doc = new DOMParser().parseFromString(data, 'text/html');
                let obj = doc.body.firstChild;
                $widget.append(obj.textContent);
            }
        });
    },
};
if (typeof jQuery === 'undefined') {
    MyWidgetJS.getScript('//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js', function() {
        return MyWidgetJS.load();
    });
} else {
    MyWidgetJS.load();
}