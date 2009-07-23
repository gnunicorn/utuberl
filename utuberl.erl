
-module(utuberl).

%% public api
-export([parse_youtube_video/1]).

%% test api
-export([test_video_parsing/0]).

parse_youtube_video(Body) ->
  Tree = mochiweb_html:parse(Body),
	Embed = mochiweb_xpath:execute("//input[@id=embed_code]", Tree),
	{Embed}.

%% Tests
test_video_parsing() ->
	{ok, Data} = file:read_file(filename:absname_join("data", "watch_choose_trainspotting")),
	Expect = dict:from_list([
			{title, "Choose (Trainspotting)"},
			{embed_code, "<object width=\"425\" height=\"344\"><param name=\"movie\" value=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"425\" height=\"344\"></embed></object>"},
			{url, "http://www.youtube.com/v/DbGhC47NSmY&hl=es&fs=1"}
			]),
	{ok, Result} = parse_youtube_video(Data),
	Result.
