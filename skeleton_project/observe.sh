./skeleton.rb
while inotifywait -r -e close_write .; do ./skeleton.rb; done
