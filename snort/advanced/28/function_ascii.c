void ExampleProcess(void *pkt, void *context)
{
    SFSnortPacket *p = (SFSnortPacket *)pkt;
    ExampleConfig *config;

    sfPolicyUserPolicySet(ex_config, _dpd.getRuntimePolicy());
    config = (ExampleConfig *)sfPolicyUserDataGetCurrent(ex_config);
    if (config == NULL)
        return;

    if (!p->ip4_header || p->ip4_header->proto != IPPROTO_TCP || !p->tcp_header)
    {
        /* Not for me, return */
        return;
    }
    
    if (p->dst_port == config->portToCheck)
    {
        /* Destination port matched, log alert */
        _dpd.alertAdd(GENERATOR_EXAMPLE, DST_PORT_MATCH,
                      1, 0, 3, DST_PORT_MATCH_STR, 0);
        
        /* Decode ASCII */
        size_t pload_size = p->payload_size;
        char pload[pload_size];
        int index = 0;
        
        /* parse the payload for ASCII decoding */
        for (int i=0; i < p->payload_size; i++){
        
            /* if % is found */
            if (p->payload[i] == '%'){
            
                /* 3 digits */
                char num_3d[4];
                num_3d[0] = p->payload[i+1];
                num_3d[1] = p->payload[i+2];
                num_3d[2] = p->payload[i+3];
                num_3d[3] = '\0';
                int i3d = atoi(num_3d);
        
                /* 2 digits */
                char num_2d[3];
                num_2d[0] = p->payload[i+1];
                num_2d[1] = p->payload[i+2];
                num_2d[2] = '\0';
                int i2d = atoi(num_2d);
        
                /* 1 digit */
                char num_1d[2];
                num_1d[0] = p->payload[i+1];
                num_1d[1] = '\0';
                int i1d = atoi(num_1d);
        
                /* check if 3 digits */
                if ((i3d != 0) && (i3d < 256) && (i3d != i2d)){
        
                    /* decode 3 digits ASCII */
                    pload[index] = i3d;
                    /* update size and index */
                    index++;
                    pload_size -= 3;
                    i += 3;
        
                /* check if 2 digits */
                } else if ((i2d != 0) && (i2d != i1d)){
                    /* decode 2 digits ASCII */
                    pload[index] = i2d;
                    /* update size and index */
                    index++;
                    pload_size -= 2;
                    i += 2;
        
                /* check if 1 digits */
                } else if (i1d != 0){
                    /* decode 1 digits ASCII */
                    pload[index] = i1d;
                    /* update size and index */
                    index++;
                    pload_size -= 1;
                    i += 1;
                    
                /* simple % - no encoding */
                } else {
                    pload[index] = p->payload[i];
                    index++;
                }
            /* normal char - no encoding */
            } else { 
                pload[index] = p->payload[i];
                index++;
            }
        }
        
        /* if there was any decoding, update payload and size */
        if (p->payload_size != pload_size){
            memcpy(p->payload, pload, pload_size);
            p->payload_size = pload_size;
        }
        return;
    }
}
