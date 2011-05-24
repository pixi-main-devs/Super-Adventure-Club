import random


#what does this thingy doo........ 
#it guesses the number in your head....
#paste it into python and see!
#wooop woop


print 'Choose a number in your head, any number at all'
raw_input("Press enter to continue: ")
print 'Now, double it (multiple by 2)'
raw_input("Press enter to continue")
rnd = random.randrange(0, 101, 2)
print 'Now, add ', rnd, ' to the number you have in your head'
raw_input("press enter to continue")
print 'Half your resut so far'
raw_input('press enter....')
print 'Whatever number you choose at the start, take it away from your result now'
raw_input('press enter....')
print ''
print 'your Result is now.........', (rnd / 2)



