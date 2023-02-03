#include <stdio.h>
#include <stdlib.h>
#include <SDL_net.h>

static TCPsocket sock = NULL;

int net_connect(const char *host, int port) {
  IPaddress a;
  if (SDLNet_ResolveHost(&a, host, port) == -1) {
    fprintf(stderr, "Error connecting to %s:%d: %s\n",
            host, port, SDLNet_GetError());
    return -1;
  }
  sock = SDLNet_TCP_Open(&a);
  if (sock == NULL) {
    fprintf(stderr, "Error connecting to %s:%d: %s\n",
            host, port, SDLNet_GetError());
    return -1;
  }
  return 0;
}

void net_close(void) {
  if (sock)
    SDLNet_TCP_Close(sock);
  sock = NULL;
}

int net_read(void *data, int n) {
  int m;
  if (sock == NULL)
    return -1;
  while (n > 0) {
    m = SDLNet_TCP_Recv(sock, data, n);
    if (m <= 0)
      return -1;
    data = (char *)data + m;
    n -= m;
  }
  return 0;
}

int net_write(const void *data, int n) {
  int m;
  if (sock == NULL)
    return -1;
  while (n > 0) {
    m = SDLNet_TCP_Send(sock, data, n);
    if (m <= 0)
      return -1;
    data = (const char *)data + n;
    n -= m;
  }
  return 0;
}
