# -*- coding: utf-8 -*-

Plugin.create(:anti_matsushita) do
  aho = %w[アホ ボケ カス バカ]
  convicted = Set.new
  judge_queue = Queue.new
  start = Time.new

  # 大量に勧められて百烈拳にならないように、一度反応したら1分キューを止める
  Thread.new do
    loop do

      Enumerator.new{|y|
        y << judge_queue.pop
      }.lazy.select { |toot|
        toot.description.include?('まちカドまぞくを見ろ') && toot.created >= start
      }.reject{|toot|
        convicted.include?(toot.uri.to_s)
      }.map { |toot|
        [toot,
         Enumerator.new{|y| Plugin.filtering(:worlds, y) }.select { |w|
           mastodon?(w)
         }.find { |w| toot.receive_user_idnames.include?(w.account.idname) }]
      }.select { |_, w|
        w
      }.each do |toot, world|
        convicted << toot.uri.to_s.freeze
        compose(toot, world, body: "@#{toot.user.idname} いやじゃ#{aho.sample}")
        sleep 60
      end
    end
  end.abort_on_exception

  on_mastodon_appear_toots do |toots|
    toots.each(&judge_queue.method(:push))
  end
end
