# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def full_name(person_id)
    Person.find(person_id).full_name rescue "No name found."
  end
  
  def get_title
    "ruby4kids"
  end
  
  def get_toc
    render :partial => '/layouts/toc'
  end
  
  def d(date)
    date.strftime('%m/%d/%y')
  end
  
  def color_syntax
    js = <<EOS
    <script language="javascript">  
    dp.SyntaxHighlighter.HighlightAll('code');  
    </script>
EOS
    js
  end
  
  
  
end
