module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-100 text-green-800 border-green-400" 
    when :alert, :error
      "bg-red-100 text-red-800 border-red-400"
    else
      "bg-blue-100 text-blue-800 border-blue-400"
    end
  end
end
