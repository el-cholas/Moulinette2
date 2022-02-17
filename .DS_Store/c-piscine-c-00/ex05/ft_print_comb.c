/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_comb.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/15 17:31:31 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/17 15:35:40 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

/*
Fucking norminette doesn't let me comment where I want to
My true love is Moulinette2, who sadly, by default, inherits
Some of Moulinettes characteristics
*/

void	print3num(char a, char b, char c)
{
	a = a + '0';
	b = b + '0';
	c = c + '0';
	write(1, &a, 1);
	write(1, &b, 1);
	write(1, &c, 1);
	if (a < '7')
	{
		write(1, ", ", 2);
	}
}

void	ft_print_comb(void)
{
	int	i;
	int	j;
	int	k;

	i = 0;
	while (i <= 7)
	{
		j = 1;
		while (j <= 8)
		{
			k = 2;
			while (k <= 9)
			{
				if (i < j && j < k)
				{
					print3num(i, j, k);
				}
				k++;
			}
			j++;
		}
		i++;
	}
}
