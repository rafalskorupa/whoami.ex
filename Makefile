include .env

make server:
	mix phx.server

make server.iex:
	iex -S mix phx.server
