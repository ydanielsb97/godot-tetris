extends Node

var client: NakamaClient
var session: NakamaSession

func _ready() -> void:
	var scheme = "http"
	var host = "127.0.0.1"
	var port = 7350
	var server_key = "custom_server_key"
	#client = Nakama.create_client(server_key, host, port, scheme)
	await authenticate()
	#print(session.token) # raw JWT token
	#print(session.user_id)
	#print(session.username)
	#print("Session has expired: %s" % session.expired)
	#print("Session expires at: %s" % session.expire_time)
	#
	#var account = await client.get_account_async(session)
	#print(account.user.id)
	#print(account.user.username)
	#print(account.wallet)

func authenticate() -> void:
	var email = "super@heroes.com"
	var password = "batsignal"
	session = await client.authenticate_email_async(email, password, null, true)
