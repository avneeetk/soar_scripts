#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#ifdef _WIN32
  #define HOSTS_FILE "C:\\Windows\\System32\\drivers\\etc\\hosts"
  #define FLUSH_CMD "ipconfig /flushdns"
#else
  #define HOSTS_FILE "/etc/hosts"
  #define FLUSH_CMD "sudo killall -HUP mDNSResponder"
#endif



#define MAX_LINE 1024

// Validate domain format
int is_valid_domain(const char *domain) {
    if (!domain || strlen(domain) < 3 || strlen(domain) > 253) return 0;

    int len = strlen(domain);
    int label_len = 0;

    for (int i = 0; i < len; i++) {
        char c = domain[i];
        if (isalnum(c)) {
            label_len++;
        } else if (c == '-') {
            if (i == 0 || domain[i-1] == '.' || domain[i+1] == '.' || !isalnum(domain[i+1])) {
                return 0; 
            }
            label_len++;
        } else if (c == '.') {
            if (i == 0 || i == len - 1 || domain[i-1] == '.' || label_len == 0) {
                return 0; 
            }
            label_len = 0;
        } else {
            return 0; 
        }
    }

    if (label_len == 0) return 0; 
    return 1;
}

// Function to check if a domain is already blocked
int is_domain_blocked(FILE *file, const char *domain) {
    char line[MAX_LINE];
    char search_string[MAX_LINE];
    
    snprintf(search_string, sizeof(search_string), "127.0.0.1 %s", domain);

    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\n")] = 0;
        if (strcmp(line, search_string) == 0) {
            return 1; 
        }
    }
    return 0; 
}

// Function to block a domain
int block_domain(const char *domain) {
    if (!is_valid_domain(domain)) {
        fprintf(stderr, "[!] Invalid domain format: %s\n", domain);
        return 1;
    }

    FILE *file = fopen(HOSTS_FILE, "r");
    if (!file) {
        perror("[!] Error opening hosts file for reading");
        return 1;
    }

    int already_blocked = is_domain_blocked(file, domain);
    fclose(file);

    if (already_blocked) {
        printf("[*] Domain %s is already blocked.\n", domain);
        return 0;
    }

    file = fopen(HOSTS_FILE, "a");
    if (!file) {
        perror("[!] Error opening hosts file for appending");
        return 1;
    }

    fprintf(file, "127.0.0.1 %s\n", domain);
    fclose(file);

    printf("[*] Domain %s has been blocked.\n", domain);

    printf("[~] Flushing DNS cache...\n");
    if (system(FLUSH_CMD) != 0) {
        fprintf(stderr, "[!] DNS cache flush command failed. This may require administrative privileges.\n");
    } else {
        printf("[*] DNS cache flushed successfully.\n");
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <domain>\n", argv[0]);
        return 1;
    }

    const char *domain_to_block = argv[1];
    
    printf("[~] Attempting to block domain: %s\n", domain_to_block);
    return block_domain(domain_to_block);
}