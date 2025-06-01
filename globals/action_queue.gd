extends Node

var actions: Array[Callable] = []
var running: bool = false


func add(function: Callable, args: Array = []) -> void:
	actions.append(function.bindv(args))
	if running: return
	running = true
	call_actions()

func call_actions() -> void:
	if actions.size() == 0: 
		running = false
		return
	
	var action: Callable = actions.pop_front()
	await action.call()
	call_actions()
