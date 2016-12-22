NonStupidDigestAssets.whitelist += [/ueditor\/.*/]


# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
paths=[]
dirs=[
    ["app/assets/javascripts/", "plugins/ueditor/**/*.*"],
]
paths += dirs.map { |base, name| Dir["#{Rails.root}/#{base}#{name}"].map { |path| path.gsub("#{Rails.root}/#{base}", '').gsub(/\.(coffee|scss|sass|erb)/, '') } }.flatten
Rails.application.config.assets.precompile += paths
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += [/.*\.js/,/.*\.css/]