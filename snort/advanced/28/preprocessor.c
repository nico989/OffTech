#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct packet{
    char* payload;
    size_t payload_size; 
} packet;	

int main(){

    char str[] = "%122%97%113%114 %122%97%113%114 fkl%97";
    packet *p = NULL;
    p = malloc (sizeof (packet));
    p->payload = str;
    p->payload_size = 39;

    /* Decode ASCII */
    size_t pload_size = p->payload_size;
    char pload[pload_size];
    int index = 0;

    // parse the payload for ASCII decoding
    for (int i=0; i < p->payload_size; i++){

	// if % is found
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
		index++;
		/* update size and index */
		pload_size -= 3;
		i += 3;

	    /* check if 2 digits */
	    } else if ((i2d != 0) && (i2d != i1d)){
		/* decode 2 digits ASCII */
		pload[index] = i2d;
		index++;

		/* update size and index */
		pload_size -= 2;
		i += 2;

	    /* check if 1 digits */
	    } else if (i1d != 0){
		/* decode 1 digits ASCII */
		pload[index] = i1d;
		index++;

		/* update size and index */
		pload_size -= 1;
		i += 1;

	    } else {
		/* normal char - no encoding */
		pload[index] = p->payload[i];
		index++;
	    }
	    
	} else { /* normal char - no encoding */
	    pload[index] = p->payload[i]; 
	    index++;
	}
    }

    /* if there was any decoding */
    if (p->payload_size != pload_size){
	memcpy(p->payload, pload, pload_size);
	p->payload_size = pload_size;
    }

    for (int i=0; i<pload_size; i++){
	printf("%c",pload[i]);
    }
    printf ("\nFinal string with size %d is: %s\n",pload_size, p->payload);

    return 0;
}

