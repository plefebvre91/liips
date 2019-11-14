# Liips

Liips is a lip-sync program written in Bash script. It creates a talking lips GIF animation from a text.

## Configuration file

### Common letters
There is a default configuration you can use, with a set of lips images. The configuration file five the association between a letter and the image to display. For exemple, if the file ```img/a.png``` represents the lips position to pronounce the letter ```a```, the entry in the configuration file will be:

```a:img/a.png```.

### Special values

There is also 2 special values, which are not letter: 'mute' and 'default'.

- `mute` represents a close mouth and it's added as the *first and last animation frames*;
- `default` is used when a letter from the speech text is not found.

## Usage

Launch the script (need to have execution rights ```chmod +x liips.bash```), you will be asked for the text to convert in lips GIF animation. The final result is produced in the current directory, in *anim.gif* file.