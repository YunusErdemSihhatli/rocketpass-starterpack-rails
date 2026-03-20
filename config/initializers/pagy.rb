require "pagy/extras/metadata"

Pagy::DEFAULT[:limit] = 20
Pagy::DEFAULT[:metadata] = %i[count page limit pages prev next]
