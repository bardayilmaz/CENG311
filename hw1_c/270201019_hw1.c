#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct dynamic_array {
    int capacity;
    int size;
    void** elements;
} dynamic_array;

typedef struct song {
    char* name;
    float duration;
} song;

// dynamic array operations
void init_array(dynamic_array* array);
void put_element(dynamic_array* array, void* element);
void remove_element(dynamic_array* array, int position);
void* get_element(dynamic_array* array, int position);

// utility functions
int find_first_available_position(dynamic_array* array);
void enlarge_array(dynamic_array* array);
void shrink_array(dynamic_array* array);

// song list operations
int find_song_index(dynamic_array* array, char* name, float duration);
void delete_song(dynamic_array* array, char* name, float duration);
void add_song(dynamic_array* array, char* name, float duration);
void list_all_songs(dynamic_array* array);

int string_equals(char str1[], char str2[], int song_name_size);

int main(int argc, char const *argv[])
{
    dynamic_array array;
    init_array(&array);
    int action = 0;
    printf("Welcome to music app, select an operation\n1. Add Song\n2. Delete song\n3. List songs\n4. Exit\n");
    scanf("%d", &action);
    while (action != 4)
    {
        if(action == 1) {
            char name[64];
            float duration;
            printf("Type song name with underscores instead of whitespaces: ");
            scanf("%s", name);
            printf("Type song duration: ");
            scanf("%f", &duration);
            printf("\n");
            add_song(&array, name, duration);
        }
        else if(action == 2) {
            char name[64];
            float duration;
            printf("Type song name with underscores instead of whitespaces: ");
            scanf("%s", name);
            printf("Type song duration: ");
            scanf("%f", &duration);
            printf("\n");
            delete_song(&array, name, duration);
        }
        else if(action == 3) {
            list_all_songs(&array);
        }
        else {
            printf("Please type valid input\n");
        }
        printf("1. Add Song\n2. Delete song\n3. List songs\n4. Exit\n");
        scanf("%d", &action);
    }
    printf("Exit...\n");
    free(array.elements);
    return 0;
}

void init_array(dynamic_array* array) {
    array->capacity = 2;
    array->size = 0;
    array->elements = malloc(2 * sizeof(void*));
    array->elements[0] = NULL;
    array->elements[1] = NULL;
}

void put_element(dynamic_array* array, void* element) {
    array->elements[array->size] = element;
    array->size++;
    if(array->size == array->capacity) {
        enlarge_array(array);
    }
}

void remove_element(dynamic_array* array, int position) {
    array->elements[position] = NULL;
    // shifting array if deletion is not at end
    if(position != array->size) {
        for(int i = position; i < array->size; i++) {
            array->elements[i] = array->elements[i+1];
        }
        array->elements[array->size] = NULL;
    }
    array->size--;
    if(array->size <= array->capacity/2) {
        shrink_array(array);
    }
}

void* get_element(dynamic_array* array, int position) {
    return array->elements[position];
}

void enlarge_array(dynamic_array* array) {
    int new_capacity = (array->capacity)*2;
    void** new_array = malloc(new_capacity * sizeof(void*));

    for(int i = 0; i < array->capacity; i++) {
        if(array->elements[i]) {
            new_array[i] = array->elements[i];
        }
        else {
            new_array[i] = NULL;
        }
    }
    for(int i = array->capacity; i < new_capacity; i++) {
        new_array[i] = NULL;
    }
    free(array->elements);
    array->elements = new_array;
    array->capacity = new_capacity;
}

int find_first_available_position(dynamic_array* array) {
    for(int i = 0; i < array->capacity; i++) {
        // if the current position is NULL, return position.
        if(!array->elements[i]) {
            return i;
        }
    }
}

void shrink_array(dynamic_array* array) {
    int new_capacity = (array->capacity)/2;
    void** new_array = malloc(new_capacity * sizeof(void*));
    for(int i = 0; i < new_capacity; i++) {
        if(array->elements[i]) {
            new_array[i] = array->elements[i];
        }
        else {
            new_array[i] = NULL;
        }
    }
    free(array->elements);
    array->elements = new_array;
    array->capacity = new_capacity;
}

void add_song(dynamic_array* array, char name[], float duration) {
    song* s = (song*)malloc(sizeof(song*));
    s->name = malloc(64 * sizeof(64));
    for(int i = 0; i < 64; i++) {
        s->name[i] = name[i];
    }
    s->duration = duration;
    put_element(array, s);
}

int find_song_index(dynamic_array* array, char name[], float duration) { 
    for(int i = 0; i < array->capacity; i++) {
        if(array->elements[i]) {
            if(((song*)(array->elements[i]))->duration - duration == 0.000000 && string_equals(((song*)(array->elements[i]))->name, name, 64) == 1) {
                return i;
            }
        }
    }
    printf("Song %s does not exist in the list\n", name);
    return -1;
}

void delete_song(dynamic_array* array, char name[], float duration) {
    int index = find_song_index(array, name, duration);
    if(index != -1) {
        song* s = array->elements[index];
        remove_element(array, index);
        free(s);
    }
}

void list_all_songs(dynamic_array* array) {
    for(int i = 0; i < array->size; i++) {
        if(array->elements[i]) {
            song s = *(song*)(array->elements[i]);
            printf("Song name: %s, duration: %f\n", s.name, s.duration);
        }
    }
}

// to avoid using string.h, I wrote a function similar to strcmp but only checks equality
int string_equals(char* str1, char* str2, int song_name_size) {
    for(int i = 0; i < song_name_size; i++) {
        if(str1[i] == '\0' || str2[i] == '\0' || str1[i] != str2[i]) {
            return 1;
        }
    }
    return 0;
}