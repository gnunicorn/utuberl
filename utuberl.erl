
-module(utuberl).

%% public api
-export([parse_youtube_video/1]).

%% test api
-export([test_video_parsing/0]).

parse_youtube_video(Body) ->
  Tree = mochiweb_html:parse(Body),
	Imgs = mochiweb_xpath:execute("//img/@src", Tree),
	{Imgs}.

%% Tests
test_video_parsing() ->
	{ok, Data} = file:read_file(filename:absname_join("data", "watch_choose_trainspotting")),
	{ok, Info} = parse_youtube_video(Data),
	[Info].
