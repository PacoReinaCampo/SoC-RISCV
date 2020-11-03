#include <stdio.h>
#include <assert.h>

#include <gzll.h>

void main() {
    int rv;
    gzll_node_id sender_node;

    printf("Receiver started, node id: %d\n", gzll_self());

    rv = gzll_lookup_nodeid("sender-0", &sender_node);
    assert(rv == 0);

    printf("Looked up sender id: %d\n", sender_node);

    gzll_mp_endpoint_t local_ep, remote_ep;

    rv = gzll_mp_endpoint_create(&local_ep, 0, OPTIMSOC_MP_EP_CHANNEL, 4, 256);
    printf("endpoint create returned %d\n", rv);

    uint32_t received = 0;
    uint32_t data[64];

    while (1) {
        rv = gzll_mp_channel_recv(local_ep, (uint8_t*) data,
                                  64 * sizeof(uint32_t), &received);

        printf("channel recv returned %d - got %d bytes\n", rv, received);
        printf("pong (%d)\n", data[63]);
    }

}
