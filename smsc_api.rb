# coding: utf-8
# Функция get_sms ( для получения SMS сообщений через API  smsc.ru )  . 
# основывается на коде  smsc.ru  https://smsc.ru/api/code/libraries/http_smtp/ruby/ 
require "net/http"
require "net/https"
require "uri"
require "erb"

class SMSC
	SMSC_LOGIN = ""			# логин клиента
	SMSC_PASSWORD = ""		# пароль
	SMSC_HTTPS = false				# использовать HTTPS протокол
	SMS_TIME = 10  # Параметр по умолчанию , за сколько часов мы смотрим SMS
	def get_sms(message,time =  SMS_TIME)
		url_orig = (SMSC_HTTPS ? "https" : "http") + "://smsc.ru/sys/get.php?get_answers=1&login=" + _urlencode(SMSC_LOGIN) + "&psw=" + _urlencode(SMSC_PASSWORD) + "&hour=" + time.to_s 
	
		url = url_orig.clone
		uri = URI.parse(url)
		http = _server_connect(uri)

		status_msg = false

		m = http.get2(uri.path + "?" + uri.query)

		msg = {}
		begin
		m.body.split(/\n/).each do |item|
			_msg = item.split(',')

			if _msg[3].split(/=/)[1].gsub(/^ /,'').scan(/\w+/).include? message
				msg['id'] = _msg[0].split(/=/)[1].gsub(/^ /,'')
				msg['received'] = _msg[1].split(/=/)[1].gsub(/^ /,'')
				msg['phone'] = _msg[2].split(/=/)[1].gsub(/^ /,'')
				msg['message'] = _msg[3].split(/=/)[1].gsub(/^ /,'')
				msg['to_phone'] = _msg[3].split(/=/)[1].gsub(/^ /,'')
				msg['send'] = _msg[4].split(/=/)[1].gsub(/^ /,'')

				status_msg = true
			end
		end	
		out = m.read_body
		rescue 
			# Если мы не получаем SMS  и выходит ошибка 
			status_msg = false
			msg = m.body
		end
		return status_msg,msg
	end
	def _server_connect(uri)
		http = Net::HTTP.new(uri.host, uri.port)

		if SMSC_HTTPS
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		end

		return http
	end
	

	def _urlencode(str)
		ERB::Util.url_encode(str)
	end
end

# Пример кода  
# require "./smsc_api"
#sms = SMSC.new()
#p sms.get_sms("Reboot",1)

