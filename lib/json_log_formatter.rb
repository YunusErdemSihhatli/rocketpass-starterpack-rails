require "json"

class JsonLogFormatter < Logger::Formatter
  def call(severity, time, progname, message)
    payload = {
      ts: time.utc.iso8601(3),
      level: severity,
      progname: progname,
      pid: Process.pid,
      message: normalize_message(message)
    }

    "#{payload.compact.to_json}\n"
  end

  private

  def normalize_message(message)
    case message
    when String
      message
    when Hash
      message
    else
      message.inspect
    end
  end
end
