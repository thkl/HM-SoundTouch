
var message_timer_id = null;

function default_error_callback(xhr, ajaxOptions, thrownError) {
			console.error(xhr)
			err = thrownError
			try {
				obj = JSON.parse(xhr.responseText);
				if (obj.error != null) {
					err = obj.error
				}
			}
			catch(e) {
			}
			display_message('error', 'uhh something went wrong ' + err, 10000)
}

function display_message(type, text, millis) {
			clear_message()
			$('#message').contents().last()[0].textContent = text
			$('#message').attr('class', 'ui ' + type + ' message visible')
			message_timer_id = setTimeout(clear_message, millis)
}
		
function clear_message() {
			if (message_timer_id != null) {
				clearTimeout(message_timer_id)
			}
			message_timer_id = null;
			$('#message').contents().last()[0].textContent = ''
			$('#message').attr('class', 'ui message hidden')
}

function rest(method, path, data, success_callback, error_callback) {
			if (!error_callback) {
				error_callback = default_error_callback
			}
			if (data != null) {
				data = JSON.stringify(data)
			}
			$.ajax({
				url: path,
				type: method,
				data: data,
				context: document.body,
				success: success_callback,
				error: error_callback
			})
}

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};

function remove_player(playername) {
	rest("GET", "index.cgi?action=removeplayer&name="+playername, null, function(data) {
	   getPlayer();
	})
}

function add_player() {
    var ip = $('#newplayer').val();
	rest("GET", "index.cgi?action=addplayer&ip="+ip, null, function(data) {
	   getPlayer();
	})
}

function getInfo() {
	rest("GET", "info.txt?date=" + new Date(), null, function(data) {
       $('#info-info tbody').empty()
       $("#info-info tbody").append($('<tr class="">').append(
						$('<td>').append(data)))
    })
    
    rest("GET", "index.cgi?action=getRefresh" , null, function(data) {
        $('#refresh').val(data.refresh)
    })
}


function saveRefresh() {
	var refreshTime = $('#refresh').val();
	$('#refresh').val("Saving ...")
	rest("GET", "index.cgi?action=setRefresh&refresh="+refreshTime , null, function(data) {
        $('#refresh').val(data.refresh)
    })
}

function getPlayer() {
	rest("GET", "index.cgi?action=listplayer", null, function(data) {
				$('#listplayer-info tbody').empty()
				data.forEach(function(player) {
				

				var btnremove = $('<div class="ui red basic button" id="button-remove-' + player.name + '">').append('Remove').attr('data-player-name', player.name)

				btnremove.click(function() {
					remove_player(this.getAttribute('data-player-name'));
				})


				$("#listplayer-info tbody").append($('<tr class="">').append(
						$('<td>').append($('<label>' + player.name + '</label>')),
						$('<td>').append($('<label>' + player.ip + '</label>')),
						$('<td>').append(btnremove)
				))
				})

				var btnadd = $('<div class="ui green basic button" id="button-add">').append('Add Player')

				btnadd.click(function() {
					add_player();
				})

				$("#listplayer-info tbody").append($('<tr class="">').append(
						$('<td>').append($('<label></label>')),
						$('<td>').append($('<label><input type="text" name="new" id="newplayer" /></label>')),
						$('<td>').append(btnadd)
				))
	})
}