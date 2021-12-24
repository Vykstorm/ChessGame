extends Node

onready var game = preload("res://GameRules.gd")

func get_moves_from_algebra(algebra):
	var moves = [
		game.Move.new(Vector2(5, 2), Vector2(5,4)),
	]
	return moves

func get_algebra_from_moves(moves):
	var algebra = []
	algebra.append("e4")
	return algebra
