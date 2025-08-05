#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN_32
  #define HOSTS_FILE "C:\\Windows\\System32\\drivers\\etc\\hosts"
  #define FLUSH_CMD "ipconfig /flushdns"
#else
  #define HOSTS_FILE "/etc/hosts"
  #define FLUSH_CMD "sudo systemd-resolve --flush-caches"
#endif

#define MAX_LINE 1024

//fucntion to check if domain is already blocked
int is_domain_blocked(FILE *file, const char *domain) {
    char line[MAX_LINE];
    while (fgets(line, sizeof(line), file)) {
        if (strstr(line, domain)) {
            return 1; // Domain is blocked
        }
    }
    return 0; 
}

// function to block a domain
int block_domain(const char *domain) {
    FILE *file = fopen(HOSTS_FILE, "r");
    if (!file) {
        perror("Error opening hosts file (read)");
        return 1;
    }

    int already_blocked = is_domain_blocked(file, domain);
    fclose(file);
    if (already_blocked) {
        printf("Domain %s is already blocked.\n", domain);
        return 0; // Domain already blocked
    }

    file = fopen(HOSTS_FILE, "a");
    if (!file) {
        perror("Error opening hosts file (append)");
        return 1;
    }

    fprintf(file, "127.0.0.1 %s\n", domain);
    fclose(file);
    printf("Domain %s has been blocked.\n", domain);

    printf("[*]Flushing DNS cache...\n");

    int flush_status = system(FLUSH_CMD);
    if (flush_status != 0) {
        perror("[*]DNS cache flush may require administrative privileges.\n");
    }else{
        printf("[*]DNS cache flushed successfully.\n");
    }
    return 0;
    }


    int main(int argc, char *argv[]) {
        if (argc != 2) {
            fprintf(stderr, "Usage: %s <domain>\n", argv[0]);
            return 1;
        }

        const char *domain = argv[1];
        printf("[~] Attempting to block domain: %s\n", domain);
        return block_domain(domain);
    }