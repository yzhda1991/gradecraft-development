namespace :lint do
  task :js do
    system "coffeelint -f coffeelint.json app/assets/javascripts"
  end
end





