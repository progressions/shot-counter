module VisibilityFilterable
  extend ActiveSupport::Concern

  private

  def apply_visibility_filter
    # Support both new visibility parameter and legacy show_hidden parameter
    visibility = params["visibility"]
    
    # Handle backward compatibility with show_hidden parameter
    if visibility.blank? && params["show_hidden"].present?
      visibility = params["show_hidden"] == "true" ? "all" : "visible"
    end
    
    # Apply visibility filter based on parameter value
    case visibility
    when "hidden"
      { active: false }
    when "all"
      { active: [true, false, nil] }
    else # "visible" or default
      { active: true }
    end
  end

  def visibility_cache_params
    [params["visibility"], params["show_hidden"]]
  end
end