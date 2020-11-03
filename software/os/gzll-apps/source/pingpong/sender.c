#include <stdio.h>
#include <assert.h>

#include <gzll.h>

void main() {
    int rv;
    gzll_node_id receiver_node;
    printf("Sender started, node id: %d\n", gzll_self());

    rv = gzll_lookup_nodeid("receiver-0", &receiver_node);
    assert(rv == 0);

    printf("Looked up receiver id: %d\n", receiver_node);

    gzll_mp_endpoint_t local_ep, remote_ep;

    rv = gzll_mp_endpoint_create(&local_ep, 0, OPTIMSOC_MP_EP_CHANNEL, 4, 256);
    printf("endpoint create returned %d\n", rv);

    rv = gzll_mp_endpoint_get(&remote_ep, receiver_node, 0);
    printf("endpoint get returned %d\n", rv);

    rv = gzll_mp_channel_connect(local_ep, remote_ep);
    printf("channel_connect returned %d\n", rv);

    printf("Connected to receiver\n");

    uint32_t cnt = 0;
    uint32_t data[64];
    while (1) {
        data[63] = cnt;

        rv = gzll_mp_channel_send(local_ep, (uint8_t*) data,
                                  64 * sizeof(uint32_t));
        printf("channel send returned %d\n", rv);
        printf("ping (%d)\n", cnt);

        cnt++;
    }
}
