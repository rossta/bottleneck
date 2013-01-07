module ApplicationHelper

  def title(text)
    content_for(:title) { text }
  end

  def render_head_title
    content_for?(:title) ? "#{content_for(:title)} | Sterno" : "Sterno"
  end

  def render_title_html
    content_tag(:h3, content_for?(:title) ? content_for(:title) : "Sterno")
  end

  def body_classes
    smush_classes controller_name, action_name, @body_classes
  end

  def add_body_classes(*body_classes)
    @body_classes = body_classes
  end

  def model_content_tag(model, tag_name, options = {}, &block)
    content_tag(tag_name, options.reverse_merge!(
      class: smush_classes(dom_class(model), options[:class]),
      id: dom_id(model),
      data: { id: model.id, type: model.class_name.underscore }
    ), &block)
  end

  def smush_classes(*classes)
    classes.compact.uniq.join(' ')
  end

  def timeago(datetime)
    datetime.getutc.iso8601
  end

  def onready(key, &block)
    onready_commands[key] = capture(&block)
  end

  def onready_commands
    @onready_commands ||= {}
  end

  def render_onready
    onready_commands.values.each { |command| content_for(:onready, command) }
    content_for(:onready)
  end

  def bare_layout
    @bare_layout = true
  end

  def bare_layout?
    @bare_layout
  end

  def generate_trello_token_key_url
    "https://trello.com/1/authorize?key=#{ENV['TRELLO_USER_KEY']}&name=#{app_name}&response_type=token&scope=read,write,account&expiration=never"
  end

  def app_name
    :bottle
  end

  def pre_signup_flow?
    false
  end

  def display_base_errors(resource)
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end
end
