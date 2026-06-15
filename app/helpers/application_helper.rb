module ApplicationHelper
  def status_badge_class(status)
    case status.to_sym
    when :pending, :queued
      "bg-gray-100 text-gray-800"
    when :processing
      "bg-blue-100 text-blue-800"
    when :completed, :sent
      "bg-green-100 text-green-800"
    when :failed
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
