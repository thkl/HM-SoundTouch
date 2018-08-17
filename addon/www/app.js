
var message_timer_id = null;
var language = navigator.language || navigator.userLanguage;

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
	var txfile = i18next.t('readme')
	rest("GET", txfile + "?date=" + new Date(), null, function(data) {
       $('#info-info tbody').empty()
       $("#info-info tbody").append($('<tr class="">').append(
						$('<td>').append(data)))
    })
    
    rest("GET", "index.cgi?action=getRefresh" , null, function(data) {
        $('#refresh').val(data.refresh)
    })
    
    rest("GET", "index.cgi?action=getVersion" , null, function(data) {
        $('#version').html(data.version)
    })
}


function saveRefresh() {
	var refreshTime = $('#refresh').val();
	$('#refresh').val(i18next.t('saving'))
	rest("GET", "index.cgi?action=setRefresh&refresh="+refreshTime , null, function(data) {
        $('#refresh').val(data.refresh)
    })
}

function getPlayer() {
	rest("GET", "index.cgi?action=listplayer", null, function(data) {
				$('#listplayer-info tbody').empty()
				data.forEach(function(player) {
				

				var btnremove = $('<div class="ui red basic button" data-i18n="remove_player" id="button-remove-' + player.name + '">').append(i18next.t('remove_player')).attr('data-player-name', player.name)

				btnremove.click(function() {
					remove_player(this.getAttribute('data-player-name'));
				})


				$("#listplayer-info tbody").append($('<tr class="">').append(
						$('<td>').append($('<label>' + player.name + '</label>')),
						$('<td>').append($('<label>' + player.ip + '</label>')),
						$('<td>').append(btnremove)
				))
				})

				var btnadd = $('<div class="ui green basic button" data-i18n="add_player" id="button-add">').append(i18next.t('add_player'))

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


$(document).ready(function() {
			i18next.init({
				lng: language,
				fallbackLng: 'en',
				resources: {
					en: {
						translation: {
							title: 'HomeMatic CCU Bose Soundtouch addon',
							listplayer : 'Player list',
							player_name : 'Player name',
							player_ip : 'IP Address',
							daemon : 'Daemon',
							save : 'Save',
							remove_player : 'Remove player',
							add_player : 'Add player',
							label_refresh : 'Refresh',
							saving : 'Saving ...',
							desc_refresh : 'The addon will auto refresh the status of all know Soundtouch devices at the given interval. Set to -1 will disable the auto refresh.',
							readme: 'info.txt',
							
						}
					},
					de: {
						translation: {
							title: 'HomeMatic CCU Bose Soundtouch Erweiterung',
							listplayer :  'Geräteliste',
							player_name : 'Name des Players',
							player_ip : 'IP Adresse',
							daemon : 'Daemon',
							save : 'Speichern',
							desc_refresh : 'Die Erweiterung wird den Status aller bekannten Soundtouch Geräte regelmässig im angegebenen Intervall aktualisieren. Die Einstellung -1 schaltet die automatische Aktualisierung aus.',
							add_player : 'Player hinzufügen',
							label_refresh : 'Aktualisierung',
							saving : 'Speichere ...',
							remove_player :'Player entfernen',
							readme: 'info_de.txt'
						}
					}
				}
			}, function(err, t) {
				jqueryI18next.init(i18next, $)
				$('title').localize()
				$('h1').localize()
				$('h2').localize()
				$('div').localize()
				$('th').localize()
				$('label').localize()
			})
			
			getPlayer()
			getInfo()
})