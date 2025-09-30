require 'pagy/extras/metadata'

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:metadata] = %i[count page items pages prev next]

