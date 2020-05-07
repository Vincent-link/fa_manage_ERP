module Helpers
  module CommonHelpers
    include SsoClient::Helpers

    def session
      env['rack.session']
    end

    def authenticate_user!
      unless current_user || @options[:path].first == '/swagger_doc'
        session['return_to'] = request.env['HTTP_REFERER']
        error!({ret: false, message: 'Unauthorized', redirect: Rails.application.routes.url_helpers.login_path}, 401)
      end
    end

    def escape_character(query)
      query = query.to_s.strip
      if query.gsub(/[A-Za-z0-9_\s\-\.]/, "").present?
        query.gsub(/[^\u4e00-\u9fa5A-Za-z0-9_\.]/, "")
      else
        query.gsub(/[^\u4e00-\u9fa5A-Za-z0-9_\s\-\.]/, "")
      end
    end

    def present(data, *options)
      is_paging = data.respond_to?(:total_entries)
      if is_paging
        super :per_page, data.per_page
        super :total_pages, data.total_pages
        super :current_page, data.current_page
        super :total_entries, data.total_entries
      end

      is_paging ? super(:data, data, *options) : super(data, *options)
    end

    def login(user)
      session['current_user_id'] = user&.id
    end

    def logout
      session.clear
    end

    def proxy(user)
      session['proxy_user_id'] = user&.id
    end

    def unproxy
      session['proxy_user_id'] = nil
    end

    def current_user
      if session['proxy_user_id']
        unless @current_user&.id == session['proxy_user_id']
          @current_user = User.find_by_id session['proxy_user_id']
          @current_user.proxier_id = session['current_user_id'] if @current_user
        end
      else
        @current_user = User.find_by_id session['current_user_id'] unless @current_user&.id == session['current_user_id']
      end
      @current_user
    end

    def skip_auth?
      if env['REQUEST_URI'] =~ /\/api\/users\/\d+\/login/ && !Rails.env.production?
        true
      else
        false
      end
    end
  end
end
