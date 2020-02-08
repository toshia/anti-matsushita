# -*- coding: utf-8 -*-

Plugin.create(:anti_matsushita) do
  aho = %w[アホ ボケ カス バカ]
  start = Time.new

  subscribe(:extract_receive_message, :mastodon_appear_toots).select { |toot|
    toot.description.include?('まちカドまぞくを見ろ') && toot.created >= start
  }.uniq.map { |toot|
    [toot,
     collect(:worlds)
       .select(&method(:mastodon?))
       .find { |w| toot.receive_user_idnames.include?(w.account.idname) }
    ]
  }.select { |_, w|
    w
  }.debounce(60).each do |toot, world|
    compose(toot, world, body: "@#{toot.user.idname} いやじゃ#{aho.sample}")
  end
end
