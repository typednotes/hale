/-
  Network.Wai.EventSource.EventStream — SSE event stream framing
-/
import Hale.WaiExtra.Network.Wai.EventSource

namespace Network.Wai.EventSource.EventStream

open Network.Wai.EventSource

/-- Create a simple data-only event. -/
def dataEvent (data : String) : ServerEvent :=
  { eventData := data.splitOn "\n" }

/-- Create a named event with data. -/
def namedEvent (name : String) (data : String) : ServerEvent :=
  { eventName := some name, eventData := data.splitOn "\n" }

/-- Create a retry event (tells client to reconnect after N ms). -/
def retryEvent (ms : Nat) : String :=
  s!"retry: {ms}\n\n"

/-- Create a comment (keep-alive ping). -/
def commentEvent (text : String := "") : String :=
  s!": {text}\n\n"

end Network.Wai.EventSource.EventStream
