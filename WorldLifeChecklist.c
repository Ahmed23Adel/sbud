#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_FEATURES 8

int num_features = 0;
int input[MAX_FEATURES];

void disable_buffering()
{
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);

    alarm(180); // Set a timeout of 3 minutes to prevent hanging
}

void print_menu()
{
    puts("Main Menu");
    puts("--------------------");
    puts("1. Load Weights");
    puts("2. Run Inference");
    puts("3. Check RAM prices");
    puts("4. Name your model");
    puts("5. Exit");
    printf("> ");
}

void check_ram_prices()
{
    puts("That's wise. RAM prices are skyrocketing! You may have to reduce the "
         "size of your linear model.");

    FILE *file = fopen("ram-prices.txt", "r");
    if (file == NULL)
    {
        perror("Error opening ram-prices.txt");
        return;
    }
    struct stat file_stat;
    stat("ram-prices.txt", &file_stat);

    char *buffer = (char *)malloc(file_stat.st_size + 1);
    fread(buffer, 1, file_stat.st_size, file);
    buffer[file_stat.st_size] = '\0';

    printf("Current price: %s\n", buffer);
    fclose(file);
    free(buffer);
}

void internal_logic()
{
    struct
    {
        bool running;
        bool weights_loaded;
        int num_weights;
        char name[140];
        int weights[8];
    } locals;

    locals.running = true;
    locals.weights_loaded = false;
    locals.num_weights = 0;

    while (locals.running)
    {
        print_menu();

        int choice;
        if (scanf("%d", &choice) != 1)
        {
            fprintf(stderr, "Invalid input. Please enter a number.\n");
            // Clear the invalid input
            int c;
            while ((c = getchar()) != '\n' && c != EOF)
                ;
            continue;
        }

        switch (choice)
        {
        case 1:
            locals.num_weights = 0;
            puts("Enter weights for your linear model (up to 8 features):");
            for (int i = 0; i < MAX_FEATURES; i++)
            {
                printf("Weight %d: ", i + 1);
                locals.num_weights++;
                if (scanf("%d", &locals.weights[i]) != 1)
                {
                    fprintf(stderr, "Invalid input. Please enter a number.\n");
                    int c;
                    while ((c = getchar()) != '\n' && c != EOF)
                        ;
                    i--; // Retry the current weight
                    continue;
                }
            }
            locals.weights_loaded = true;
            break;
        case 2:
            puts("Enter input features for inference (up to 8 features):");
            if (!locals.weights_loaded)
            {
                puts("Weights not loaded. Please load weights before running inference.");
                break;
            }
            for (int i = 0; i < locals.num_weights; i++)
            {
                printf("Feature %d: ", i + 1);
                if (scanf("%d", &input[i]) != 1)
                {
                    fprintf(stderr, "Invalid input. Please enter a number.\n");
                    int c;
                    while ((c = getchar()) != '\n' && c != EOF)
                        ;
                    i--; // Retry the current weight
                    continue;
                }
            }

            int output = 0;
            for (int i = 0; i < locals.num_weights; i++)
            {
                output += locals.weights[i] * input[i];
            }
            printf("Inference output: %d\n", output);

            break;
        case 3:
            check_ram_prices();
            break;
        case 4:
            // Consume the newline left by previous scanf
            while (getchar() != '\n')
                ;

            printf("Enter a name for your model: ");
            gets(locals.name);
            printf("Model named: %s\n", locals.name);
            break;
        case 5:
            puts("Exiting program.");
            locals.running = false;
            break;
        default:
            puts("Invalid choice. Please try again.");
            break;
        }
    }
}

int main(int argc, char *argv[], char *envp[])
{
    puts("Linear AI - Version 1.0.0");
    puts("Copyright 2026 Linear AI - All Rights Reserved.");
    puts("----------------------------------------------------");
    puts("Quote of the Day:");
    puts("Commercial LLMs are so damn expensive, but we had quantized local AI "
         "ages ago! ~Winston Churchill");
    puts("");

    disable_buffering();

    internal_logic();
    return 0;
}
