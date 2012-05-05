
require 'logbook'
require 'thor'
require 'user_config'



class Logbook::CLI < Thor

  desc "book?", "which book are we on?"
  def book?
    j = current_book
    return unless j
    say config[:books][j.id]
  end

  desc "book [ID]", "open a book"
  def book(*params)
    text = params.join ' '
    config[:books] ||= {}

    # no argument given: prompt user to switch books from a menu
    if text.empty? && !config[:books].empty?
      choices = config[:books].to_a
      choices = choices.map.with_index{ |a, i| [i+1, *a]}
      print_table choices
      selection = ask("Pick one:").to_i
      if selection == 0 || choices.size < selection
        error "No such option"
        return
      end

      selected_id = choices[selection-1][1]
      self.current_book = selected_id
      ok "selected"
      return
    end

    # we have an argument, switch to, or create a new one.
    if config[:books].has_key? text
      self.current_book = text
      ok "switched"
    else
      if yes? "Create #{em(text)}?"
        j = Logbook::Book.new
        begin
          id = j.create text
          self.current_book = id

          config[:books][id] = text
          config.save 
          ok "saved '#{text}' as #{em(id)}"
        rescue
          error $!
        end
      end
    end
  end

  desc "add MEMORY", "add a new memory"
  def add(*memory)
    text = memory.join ' '
    j = current_book
    return unless j
    begin
      time = j.add_temporal text
      ok("at #{em(time.to_s)}")
    rescue
      error $!
    end
  end

  desc "all", "list the entire book"
  def all
    j = current_book
    begin
      data = j.all
      say "[#{em data[:cover]}]\n"
      data[:entries].group_by{|g| g[:date]}.each do |key, entries|
        say "#{em key.strftime("%A, %d-%b-%Y")}"
        entries.each do |entry|
          say "#{entry[:content]}"
        end
      end
    rescue
      error $!
    end
  end


private 
  def current_book
    id = config[:current_book]
    unless id
      error "No book is set. Create one with $ lg book #{em 'My Stories Unfold'}."
      return nil
    end
    
    Logbook::Book.new id
  end

  def current_book=(id)
    config[:current_book] = id
    config.save
  end

  def config
    @uconf ||= UserConfig.new(".logbook")
    @uconf["logbook.yaml"]
  end

  def em(text)
    shell.set_color(text, nil, true)
  end

  def ok(detail=nil)
    text = detail ? "OK, #{detail}." : "OK."
    say text, :green
  end

  def error(detail)
    say detail, :red
  end


end

