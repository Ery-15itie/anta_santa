module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice then "bg-green-500 text-white"
    when :alert  then "bg-red-500 text-white"
    when :error  then "bg-red-500 text-white"
    when :success then "bg-green-500 text-white"
    when :warning then "bg-yellow-500 text-gray-800"
    else "bg-gray-500 text-white"
    end
  end
end
