/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_sort_int_tab.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/17 22:21:15 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/17 22:52:39 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <unistd.h>

void	ft_sort_int_tab(int *tab, int size)
{
	int	i;
	int	j;
	int	current_int;

	i = 0;
	j = 0;
	while (i < size)
	{
		while (j < size)
		{
			if (tab[i] > tab[j])
			{
				current_int = tab[i];
				tab[i] = tab[j];
				tab[j] = current_int;
			}
			j++;
		}
		i++;
		j = i + 1;
	}
}
