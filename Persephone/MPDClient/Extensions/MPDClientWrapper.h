//
//  MPDClientWrapper.h
//  Persephone
//
//  Created by Daniel Barber on 1/31/20.
//  Copyright © 2020 Dan Barber. All rights reserved.
//

#include <mpd/client.h>

int
mpd_send_albumart(struct mpd_connection *connection, const char * uri, const char * offset);
